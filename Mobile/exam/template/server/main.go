package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"sync"

	"github.com/gorilla/websocket"
)

// ============================================================
// MODEL - schimba campurile in functie de subiect
// ============================================================

type Item struct {
	ID   int    `json:"id"`
	Text string `json:"text"`
	// adauga campuri dupa subiect: date, quantity, read, sender, room, etc.
}

// ============================================================
// IN-MEMORY STORE
// ============================================================

var (
	items  = []Item{}
	nextID = 1
	mu     sync.Mutex
)

func init() {
	// seed cu date initiale
	for i := 1; i <= 25; i++ {
		items = append(items, Item{ID: i, Text: fmt.Sprintf("Item %d", i)})
	}
	nextID = 26
}

// ============================================================
// WEBSOCKET
// ============================================================

var upgrader = websocket.Upgrader{CheckOrigin: func(r *http.Request) bool { return true }}

var (
	clients   = map[*websocket.Conn]bool{}
	clientsMu sync.Mutex
)

func broadcast(msg interface{}) {
	data, _ := json.Marshal(msg)
	clientsMu.Lock()
	defer clientsMu.Unlock()
	for c := range clients {
		c.WriteMessage(websocket.TextMessage, data)
	}
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		return
	}
	clientsMu.Lock()
	clients[conn] = true
	clientsMu.Unlock()
	defer func() {
		clientsMu.Lock()
		delete(clients, conn)
		clientsMu.Unlock()
		conn.Close()
	}()
	// keep connection alive - citim mesaje dar nu facem nimic cu ele
	for {
		if _, _, err := conn.ReadMessage(); err != nil {
			break
		}
	}
}

// ============================================================
// CORS middleware
// ============================================================

func cors(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		if r.Method == "OPTIONS" {
			w.WriteHeader(200)
			return
		}
		next(w, r)
	}
}

// ============================================================
// HANDLERS
// ============================================================

// GET /item           - toate itemele
// GET /item?page=1    - paginat (10 per pagina)
func getItems(w http.ResponseWriter, r *http.Request) {
	mu.Lock()
	defer mu.Unlock()

	pageStr := r.URL.Query().Get("page")
	if pageStr == "" {
		// returnez toate
		json.NewEncoder(w).Encode(items)
		return
	}

	page, _ := strconv.Atoi(pageStr)
	if page < 1 {
		page = 1
	}
	perPage := 10
	total := len(items)
	totalPages := (total + perPage - 1) / perPage
	start := (page - 1) * perPage
	end := start + perPage
	if start > total {
		start = total
	}
	if end > total {
		end = total
	}

	resp := map[string]interface{}{
		"total": total,
		"page":  page,
		"pages": totalPages,
		"items": items[start:end],
	}
	json.NewEncoder(w).Encode(resp)
}

// POST /item - creeaza un item
func postItem(w http.ResponseWriter, r *http.Request) {
	var item Item
	if err := json.NewDecoder(r.Body).Decode(&item); err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	mu.Lock()
	item.ID = nextID
	nextID++
	items = append(items, item)
	mu.Unlock()

	w.WriteHeader(201)
	json.NewEncoder(w).Encode(item)

	// notifica clientii prin ws
	broadcast(map[string]interface{}{"event": "created", "item": item})
}

// PUT /item/:id - update un item
func putItem(w http.ResponseWriter, r *http.Request, id int) {
	var updated Item
	if err := json.NewDecoder(r.Body).Decode(&updated); err != nil {
		http.Error(w, err.Error(), 400)
		return
	}
	mu.Lock()
	defer mu.Unlock()
	for i, item := range items {
		if item.ID == id {
			updated.ID = id
			items[i] = updated
			json.NewEncoder(w).Encode(updated)
			broadcast(map[string]interface{}{"event": "updated", "item": updated})
			return
		}
	}
	http.Error(w, "not found", 404)
}

// DELETE /item/:id - sterge un item
func deleteItem(w http.ResponseWriter, r *http.Request, id int) {
	mu.Lock()
	defer mu.Unlock()
	for i, item := range items {
		if item.ID == id {
			items = append(items[:i], items[i+1:]...)
			json.NewEncoder(w).Encode(item)
			broadcast(map[string]interface{}{"event": "deleted", "item": item})
			return
		}
	}
	http.Error(w, "not found", 404)
}

// ============================================================
// ROUTER
// ============================================================

func itemHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// extrage id din path: /item/123
	path := r.URL.Path[len("/item"):]
	if path == "" || path == "/" {
		switch r.Method {
		case "GET":
			getItems(w, r)
		case "POST":
			postItem(w, r)
		default:
			http.Error(w, "method not allowed", 405)
		}
		return
	}

	// /item/:id
	id, err := strconv.Atoi(path[1:])
	if err != nil {
		http.Error(w, "invalid id", 400)
		return
	}

	switch r.Method {
	case "PUT":
		putItem(w, r, id)
	case "DELETE":
		deleteItem(w, r, id)
	default:
		http.Error(w, "method not allowed", 405)
	}
}

func main() {
	http.HandleFunc("/item", cors(itemHandler))
	http.HandleFunc("/item/", cors(itemHandler))
	http.HandleFunc("/ws", wsHandler)

	log.Println("Server running on :3000")
	log.Fatal(http.ListenAndServe(":3000", nil))
}
