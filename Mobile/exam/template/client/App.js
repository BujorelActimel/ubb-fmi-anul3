import { useEffect, useState, useCallback, useRef } from "react";
import {
  View,
  Text,
  FlatList,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  Alert,
  StyleSheet,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

// const API = "http://10.0.2.2:3000"; // android emulator -> localhost
const API = "http://localhost:3000"; // web
const WS = "ws://localhost:3000/ws";

// ============================================================
// API HELPERS
// ============================================================

async function fetchItems() {
  const res = await fetch(`${API}/item`);
  if (!res.ok) throw new Error("fetch failed");
  return res.json();
}

// paginat - returneaza { items, total, pages }
async function fetchPage(page) {
  const res = await fetch(`${API}/item?page=${page}`);
  if (!res.ok) throw new Error("fetch page failed");
  return res.json();
}

async function postItem(item) {
  const res = await fetch(`${API}/item`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(item),
  });
  if (!res.ok) throw new Error("post failed");
  return res.json();
}

async function putItem(id, item) {
  const res = await fetch(`${API}/item/${id}`, {
    method: "PUT",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(item),
  });
  if (!res.ok) throw new Error("put failed");
  return res.json();
}

async function deleteItem(id) {
  const res = await fetch(`${API}/item/${id}`, { method: "DELETE" });
  if (!res.ok) throw new Error("delete failed");
  return res.json();
}

// ============================================================
// PERSISTENCE
// ============================================================

const STORAGE_KEY = "items";

async function saveLocal(data) {
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(data));
}

async function loadLocal() {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);
  return raw ? JSON.parse(raw) : [];
}

// ============================================================
// APP
// ============================================================

export default function App() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // form state - adapteaza dupa subiect
  const [text, setText] = useState("");

  // upload status per item: { [localId]: 'pending' | 'submitting' | 'submitted' | 'failed' }
  const [uploadStatus, setUploadStatus] = useState({});

  // download progress (pt paginare)
  const [downloadProgress, setDownloadProgress] = useState("");

  const ws = useRef(null);

  // ----------------------------------------------------------
  // FETCH DATA (simplu - toate odata)
  // ----------------------------------------------------------
  const loadData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await fetchItems();
      setItems(data);
      await saveLocal(data);
    } catch (e) {
      setError(e.message);
      // fallback pe date locale
      const local = await loadLocal();
      if (local.length) setItems(local);
    } finally {
      setLoading(false);
    }
  }, []);

  // ----------------------------------------------------------
  // FETCH DATA (paginat)
  // ----------------------------------------------------------
  const loadPaginated = useCallback(async (startPage = 1) => {
    setLoading(true);
    setError(null);
    try {
      let page = startPage;
      let allItems = startPage === 1 ? [] : [...items];
      let totalPages = 1;

      // prima pagina ca sa aflam totalul
      const first = await fetchPage(page);
      totalPages = first.pages;
      allItems = allItems.concat(first.items);
      setDownloadProgress(`${page}/${totalPages}`);
      page++;

      while (page <= totalPages) {
        const resp = await fetchPage(page);
        allItems = allItems.concat(resp.items);
        setDownloadProgress(`${page}/${totalPages}`);
        page++;
      }

      setItems(allItems);
      await saveLocal(allItems);
      setDownloadProgress("");
    } catch (e) {
      setError(e.message);
      const local = await loadLocal();
      if (local.length) setItems(local);
    } finally {
      setLoading(false);
    }
  }, [items]);

  // ----------------------------------------------------------
  // WEBSOCKET
  // ----------------------------------------------------------
  useEffect(() => {
    const connect = () => {
      ws.current = new WebSocket(WS);
      ws.current.onmessage = (e) => {
        const msg = JSON.parse(e.data);
        console.log("ws:", msg);
        // adapteaza dupa subiect:
        if (msg.event === "created") {
          setItems((prev) => [...prev, msg.item]);
        } else if (msg.event === "deleted") {
          setItems((prev) => prev.filter((i) => i.id !== msg.item.id));
        } else if (msg.event === "updated") {
          setItems((prev) =>
            prev.map((i) => (i.id === msg.item.id ? msg.item : i))
          );
        }
      };
      ws.current.onclose = () => {
        // reconectare automata
        setTimeout(connect, 3000);
      };
    };
    connect();
    return () => ws.current?.close();
  }, []);

  // ----------------------------------------------------------
  // LOAD INITIAL
  // ----------------------------------------------------------
  useEffect(() => {
    loadData();
    // sau: loadPaginated();
  }, []);

  // ----------------------------------------------------------
  // ADD ITEM (local + server)
  // ----------------------------------------------------------
  const handleAdd = async () => {
    if (!text.trim()) return;
    const newItem = { text: text.trim(), _localId: Date.now() };
    const updated = [...items, newItem];
    setItems(updated);
    setText("");
    await saveLocal(updated);

    // trimite la server
    try {
      const saved = await postItem({ text: newItem.text });
      setItems((prev) =>
        prev.map((i) => (i._localId === newItem._localId ? saved : i))
      );
    } catch (e) {
      Alert.alert("Error", "Failed to save to server");
    }
  };

  // ----------------------------------------------------------
  // DELETE ITEM
  // ----------------------------------------------------------
  const handleDelete = (item) => {
    Alert.alert("Confirm", `Delete "${item.text}"?`, [
      { text: "Cancel" },
      {
        text: "Delete",
        style: "destructive",
        onPress: async () => {
          setItems((prev) => prev.filter((i) => i.id !== item.id));
          try {
            await deleteItem(item.id);
          } catch (e) {
            Alert.alert("Error", "Delete failed, will retry");
            // marcheaza ca pending delete pt retry
          }
        },
      },
    ]);
  };

  // ----------------------------------------------------------
  // UPLOAD ITEMS (trimite pe rand cu progress)
  // ----------------------------------------------------------
  const handleUpload = async () => {
    const toUpload = items.filter((i) => i._localId); // cele netrimise
    for (const item of toUpload) {
      const key = item._localId;
      setUploadStatus((prev) => ({ ...prev, [key]: "submitting" }));
      try {
        await postItem({ text: item.text });
        setUploadStatus((prev) => ({ ...prev, [key]: "submitted" }));
      } catch (e) {
        setUploadStatus((prev) => ({ ...prev, [key]: "failed" }));
      }
    }
  };

  // ----------------------------------------------------------
  // RETRY FAILED
  // ----------------------------------------------------------
  const retryFailed = async () => {
    const failed = Object.entries(uploadStatus)
      .filter(([_, v]) => v === "failed")
      .map(([k]) => Number(k));
    for (const localId of failed) {
      const item = items.find((i) => i._localId === localId);
      if (!item) continue;
      setUploadStatus((prev) => ({ ...prev, [localId]: "submitting" }));
      try {
        await postItem({ text: item.text });
        setUploadStatus((prev) => ({ ...prev, [localId]: "submitted" }));
      } catch {
        setUploadStatus((prev) => ({ ...prev, [localId]: "failed" }));
      }
    }
  };

  // ----------------------------------------------------------
  // RENDER
  // ----------------------------------------------------------

  const renderItem = ({ item }) => {
    const status = uploadStatus[item._localId];
    return (
      <TouchableOpacity
        style={styles.item}
        onLongPress={() => handleDelete(item)}
      >
        <Text style={styles.itemText}>
          {item.text || item.id}
        </Text>
        {status && (
          <Text
            style={[
              styles.status,
              status === "submitted" && { color: "green" },
              status === "failed" && { color: "red" },
            ]}
          >
            {status === "submitting" ? (
              <ActivityIndicator size="small" />
            ) : (
              status
            )}
          </Text>
        )}
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Template App</Text>

      {/* ERROR */}
      {error && <Text style={styles.error}>{error}</Text>}

      {/* DOWNLOAD PROGRESS */}
      {loading && (
        <View style={styles.row}>
          <ActivityIndicator />
          <Text style={{ marginLeft: 8 }}>
            {downloadProgress ? `Downloading ${downloadProgress}` : "Loading..."}
          </Text>
        </View>
      )}

      {/* SEARCH / INPUT */}
      <View style={styles.row}>
        <TextInput
          style={styles.input}
          placeholder="Text..."
          value={text}
          onChangeText={setText}
        />
        <TouchableOpacity style={styles.btn} onPress={handleAdd}>
          <Text style={styles.btnText}>Add</Text>
        </TouchableOpacity>
      </View>

      {/* LIST */}
      <FlatList
        data={items}
        keyExtractor={(item) => String(item.id || item._localId)}
        renderItem={renderItem}
        style={styles.list}
      />

      {/* ACTION BUTTONS */}
      <View style={styles.row}>
        <TouchableOpacity style={styles.btn} onPress={loadData}>
          <Text style={styles.btnText}>Refresh</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.btn} onPress={handleUpload}>
          <Text style={styles.btnText}>Upload</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

// ============================================================
// STYLES
// ============================================================

const styles = StyleSheet.create({
  container: { flex: 1, paddingTop: 50, paddingHorizontal: 16, backgroundColor: "#fff" },
  title: { fontSize: 22, fontWeight: "bold", marginBottom: 12 },
  error: { color: "red", marginBottom: 8 },
  row: { flexDirection: "row", alignItems: "center", marginBottom: 8, gap: 8 },
  input: {
    flex: 1,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 6,
    padding: 8,
    fontSize: 16,
  },
  btn: {
    backgroundColor: "#007AFF",
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 6,
  },
  btnText: { color: "#fff", fontWeight: "bold" },
  list: { flex: 1, marginVertical: 8 },
  item: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    padding: 12,
    borderBottomWidth: 1,
    borderBottomColor: "#eee",
  },
  itemText: { fontSize: 16, flex: 1 },
  status: { fontSize: 12, marginLeft: 8 },
});
