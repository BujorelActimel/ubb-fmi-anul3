import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View, TouchableOpacity, TextInput, Alert, FlatList, ScrollView, Image, Animated, Platform } from 'react-native';
import { useState, useEffect, useRef } from 'react';
import { CameraView, useCameraPermissions } from 'expo-camera';
import MapView, { Marker } from 'react-native-maps';
import * as Location from 'expo-location';
import NetInfo from '@react-native-community/netinfo';
import * as MediaLibrary from 'expo-media-library';
import * as FileSystem from 'expo-file-system/legacy';
import * as NavigationBar from 'expo-navigation-bar';
import { SafeAreaProvider, useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { api } from './src/api';
import { storage } from './src/storage';
import { wsService } from './src/websocket';
import { database } from './src/database';

// Animated Trail Card Component
const AnimatedTrailCard = ({ item, index, onPress }: any) => {
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;

  useEffect(() => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 400,
        delay: index * 100,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 400,
        delay: index * 100,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  return (
    <Animated.View
      style={{
        opacity: fadeAnim,
        transform: [{ translateY: slideAnim }],
      }}
    >
      <TouchableOpacity style={[styles.trailCard, item.isPending && styles.trailCardPending]} onPress={onPress}>
        <View style={{ flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' }}>
          <Text style={styles.trailName}>{item.name}</Text>
          {item.isPending && (
            <Ionicons name="cloud-upload-outline" size={16} color="#d79921" />
          )}
        </View>
        <Text style={styles.trailInfo}>
          {item.distance}km • {item.difficulty}
        </Text>
      </TouchableOpacity>
    </Animated.View>
  );
};

// Animated Button Component
const AnimatedButton = ({ onPress, style, children }: any) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;

  const handlePressIn = () => {
    Animated.spring(scaleAnim, {
      toValue: 0.95,
      useNativeDriver: true,
    }).start();
  };

  const handlePressOut = () => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      friction: 3,
      tension: 40,
      useNativeDriver: true,
    }).start();
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
      activeOpacity={0.8}
    >
      <Animated.View style={[style, { transform: [{ scale: scaleAnim }] }]}>
        {children}
      </Animated.View>
    </TouchableOpacity>
  );
};

function AppContent() {
  const insets = useSafeAreaInsets();
  const [screen, setScreen] = useState('loading');
  const [isRegister, setIsRegister] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [username, setUsername] = useState('');
  const [loading, setLoading] = useState(false);
  const [trails, setTrails] = useState([]);
  const [trailName, setTrailName] = useState('');
  const [distance, setDistance] = useState('');
  const [difficulty, setDifficulty] = useState('easy');
  const [selectedTrail, setSelectedTrail] = useState<any>(null);
  const [trailPhotos, setTrailPhotos] = useState<{ [key: number]: string[] }>({});
  const [cameraPermission, requestCameraPermission] = useCameraPermissions();
  const cameraRef = useRef<any>(null);
  const [location, setLocation] = useState<any>(null);
  const [startLocation, setStartLocation] = useState<any>(null);
  const [endLocation, setEndLocation] = useState<any>(null);
  const [pickingLocationFor, setPickingLocationFor] = useState<'start' | 'end'>('start');
  const [isOnline, setIsOnline] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterDifficulty, setFilterDifficulty] = useState('');
  const [pendingSync, setPendingSync] = useState<any[]>([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [cameraFacing, setCameraFacing] = useState<'front' | 'back'>('back');
  const [isEditing, setIsEditing] = useState(false);
  const [serverPhotos, setServerPhotos] = useState<any[]>([]);
  const [pendingPhotos, setPendingPhotos] = useState<any[]>([]);
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const spinAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    database.init();
    checkToken();
    loadPhotos();

    // Set navigation bar on Android
    if (Platform.OS === 'android') {
      NavigationBar.setButtonStyleAsync('light').catch(() => {});
      NavigationBar.setVisibilityAsync('visible').catch(() => {});
    }
  }, []);

  // Keep navigation bar styled on screen changes
  useEffect(() => {
    if (Platform.OS === 'android') {
      NavigationBar.setButtonStyleAsync('light').catch(() => {});
    }
  }, [screen]);

  useEffect(() => {
    if (screen === 'home') {
      setPage(1);
      loadTrails(1, false);
    }
  }, [screen, filterDifficulty]);

  useEffect(() => {
    if (screen === 'home') {
      const timer = setTimeout(() => {
        setPage(1);
        loadTrails(1, false);
      }, 150);
      return () => clearTimeout(timer);
    }
  }, [searchQuery]);

  useEffect(() => {
    getCurrentLocation();
  }, []);

  useEffect(() => {
    storage.savePhotos(trailPhotos);
  }, [trailPhotos]);

  useEffect(() => {
    fadeAnim.setValue(0);
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 300,
      useNativeDriver: true,
    }).start();
  }, [screen]);

  useEffect(() => {
    if (screen === 'loading' || loadingMore) {
      const animation = Animated.loop(
        Animated.timing(spinAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        })
      );
      animation.start();
      return () => animation.stop();
    }
  }, [screen, loadingMore]);

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      const online = state.isConnected ?? true;
      setIsOnline(online);
      if (online && !isOnline) {
        // Just went online, try to sync
        syncPendingTrails();
      }
    });
    return () => unsubscribe();
  }, [isOnline]);

  useEffect(() => {
    loadPendingSync();
    loadPendingPhotos();
  }, []);

  useEffect(() => {
    // Connect WebSocket after login
    if (screen !== 'login' && screen !== 'loading') {
      wsService.connect();

      const handleWSMessage = (message: any) => {
        if (message.type === 'trail_update') {
          Alert.alert('Trail Updated', message.payload.message);
          if (screen === 'home') {
            loadTrails(1, false);
          }
        }
      };

      wsService.addListener(handleWSMessage);

      return () => {
        wsService.removeListener(handleWSMessage);
      };
    }
  }, [screen]);

  useEffect(() => {
    return () => {
      wsService.disconnect();
    };
  }, []);

  useEffect(() => {
    const loadServerPhotos = async () => {
      if (selectedTrail && screen === 'trailDetail') {
        if (isOnline) {
          try {
            const data = await api.getPhotos(selectedTrail.id);
            const photos = data.photos || [];
            setServerPhotos(photos);
            // Cache photos to SQLite
            database.savePhotos(selectedTrail.id, photos);
          } catch (error) {
            // Load from cache when network fails
            const cached = database.getPhotos(selectedTrail.id);
            setServerPhotos(cached);
          }
        } else {
          // Load from cache when offline
          const cached = database.getPhotos(selectedTrail.id);
          setServerPhotos(cached);
        }
      } else {
        setServerPhotos([]);
      }
    };
    loadServerPhotos();
  }, [selectedTrail, screen, isOnline]);

  const loadPendingSync = async () => {
    const pending = await storage.getPendingTrails();
    setPendingSync(pending);
  };

  const loadPendingPhotos = async () => {
    const pending = await storage.getPendingPhotos();
    setPendingPhotos(pending);
  };

  const syncPendingTrails = async () => {
    const pending = await storage.getPendingTrails();
    for (const trail of pending) {
      try {
        await api.createTrail(trail);
        await storage.removePendingTrail(trail.tempId);
      } catch (error) {
        // Will retry on next sync
      }
    }
    await loadPendingSync();
    await syncPendingPhotos();
    setPage(1);
    await loadTrails(1, false);
  };

  const syncPendingPhotos = async () => {
    const pending = await storage.getPendingPhotos();
    for (const photo of pending) {
      try {
        await api.uploadPhoto(photo.trailId, photo.photoUri);
        await storage.removePendingPhoto(photo.tempId);
      } catch (error) {
        // Will retry on next sync
      }
    }
    await loadPendingPhotos();
  };

  const getCurrentLocation = async () => {
    try {
      const { status } = await Location.requestForegroundPermissionsAsync();
      if (status !== 'granted') {
        console.log('Location permission denied');
        return;
      }

      const currentLocation = await Location.getCurrentPositionAsync({});
      setLocation({
        latitude: currentLocation.coords.latitude,
        longitude: currentLocation.coords.longitude,
        latitudeDelta: 0.01,
        longitudeDelta: 0.01,
      });
    } catch (error) {
      console.error('Error getting location:', error);
    }
  };

  const checkToken = async () => {
    const token = await storage.getToken();
    setScreen(token ? 'home' : 'login');
  };

  const loadPhotos = async () => {
    const savedPhotos = await storage.getPhotos();
    setTrailPhotos(savedPhotos);
  };

  const handleLogin = async () => {
    if (!email || !password) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const result = await api.login(email, password);
      await storage.saveToken(result.token);
      setScreen('home');
      Alert.alert('Success', `Welcome ${result.user.username}!`);
    } catch (error: any) {
      Alert.alert('Login Failed', error.response?.data?.error || 'Please try again');
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async () => {
    if (!email || !password || !username) {
      Alert.alert('Error', 'Please fill in all fields');
      return;
    }

    setLoading(true);
    try {
      const result = await api.register(username, email, password);
      await storage.saveToken(result.token);
      setScreen('home');
      Alert.alert('Success', `Welcome ${result.user.username}!`);
    } catch (error: any) {
      Alert.alert('Registration Failed', error.response?.data?.error || 'Please try again');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    await storage.removeToken();
    setScreen('login');
    setEmail('');
    setPassword('');
    setUsername('');
  };

  const loadTrails = async (pageNum: number = 1, append: boolean = false) => {
    try {
      const params: any = { page: pageNum, limit: 10 };
      if (searchQuery) params.search = searchQuery;
      if (filterDifficulty) params.difficulty = filterDifficulty;

      const data = await api.getTrails(params);
      const newTrails = data.trails || [];

      // Cache to SQLite
      if (newTrails.length > 0) {
        database.saveTrails(newTrails);
      }

      if (append) {
        setTrails(prev => [...prev, ...newTrails]);
      } else {
        setTrails(newTrails);
      }

      setHasMore(newTrails.length === 10);
      setPage(pageNum);
    } catch (error) {
      // Load from SQLite when offline (silently handle network errors)
      const cached = database.getTrails(pageNum, 10, searchQuery || undefined, filterDifficulty || undefined);
      if (append) {
        setTrails(prev => [...prev, ...cached]);
      } else {
        setTrails(cached);
      }
      setHasMore(cached.length === 10);
      setPage(pageNum);
    }
  };

  const loadMoreTrails = async () => {
    if (loadingMore || !hasMore) return;
    console.log('Loading more trails, page:', page + 1);
    setLoadingMore(true);
    await loadTrails(page + 1, true);
    setLoadingMore(false);
  };

  if (screen === 'loading') {
    const spin = spinAnim.interpolate({
      inputRange: [0, 1],
      outputRange: ['0deg', '360deg'],
    });

    return (
      <Animated.View style={[styles.container, styles.centered, { opacity: fadeAnim }]}>
        <Animated.View style={{ transform: [{ rotate: spin }] }}>
          <Ionicons name="sync" size={48} color="#8ec07c" />
        </Animated.View>
        <Text style={[styles.subtitle, { marginTop: 20 }]}>Loading...</Text>
        <StatusBar style="light" translucent backgroundColor="transparent" />
      </Animated.View>
    );
  }

  if (screen === 'camera') {
    if (!cameraPermission) {
      return (
        <View style={[styles.container, styles.centered]}>
          <Text style={styles.subtitle}>Loading camera...</Text>
        </View>
      );
    }

    if (!cameraPermission.granted) {
      return (
        <View style={[styles.container, styles.centered, { paddingTop: insets.top, paddingBottom: insets.bottom }]}>
          <View style={{ alignItems: 'center', paddingHorizontal: 24 }}>
            <Text style={[styles.title, { flex: 0, marginBottom: 12 }]}>Camera Access</Text>
            <Text style={[styles.subtitle, { marginBottom: 24, textAlign: 'center' }]}>We need your permission to use the camera</Text>
            <TouchableOpacity style={[styles.button, { width: '100%' }]} onPress={requestCameraPermission}>
              <Text style={styles.buttonText}>Grant Permission</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.linkButton} onPress={() => setScreen('trailDetail')}>
              <Text style={styles.linkText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      );
    }

    const takePicture = async () => {
      if (cameraRef.current && selectedTrail) {
        try {
          const photo = await cameraRef.current.takePictureAsync();
          const trailId = selectedTrail.id;

          // Upload photo if online
          if (isOnline) {
            try {
              await api.uploadPhoto(trailId, photo.uri);
              // Reload photos from server
              const data = await api.getPhotos(trailId);
              setServerPhotos(data.photos || []);
              console.log('Photo uploaded successfully');
            } catch (uploadError) {
              // Save to pending queue on upload failure
              await storage.addPendingPhoto(trailId, photo.uri);
              await loadPendingPhotos();
              Alert.alert('Photo Saved', 'Photo saved locally. Will upload when online.');
            }
          } else {
            // Save to pending queue when offline
            await storage.addPendingPhoto(trailId, photo.uri);
            await loadPendingPhotos();
            Alert.alert('Photo Saved', 'Photo saved locally. Will upload when online.');
          }

          setScreen('trailDetail');
        } catch (error) {
          console.error('Failed to take picture:', error);
          Alert.alert('Error', 'Failed to take picture');
        }
      }
    };

    return (
      <View style={styles.cameraContainer}>
        <CameraView style={styles.camera} ref={cameraRef} facing={cameraFacing}>
          <View style={styles.cameraControls}>
            <TouchableOpacity
              style={styles.cameraButton}
              onPress={takePicture}
            >
              <View style={styles.cameraButtonInner} />
            </TouchableOpacity>
          </View>
        </CameraView>
        <TouchableOpacity
          style={styles.cameraCloseButton}
          onPress={() => setScreen('trailDetail')}
        >
          <Ionicons name="close" size={24} color="#fbf1c7" />
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.cameraFlipButton}
          onPress={() => setCameraFacing(prev => prev === 'back' ? 'front' : 'back')}
        >
          <Ionicons name="camera-reverse" size={24} color="#fbf1c7" />
        </TouchableOpacity>
        <StatusBar style="light" translucent backgroundColor="transparent" />
      </View>
    );
  }

  if (screen === 'pickLocation') {
    const defaultRegion = location || {
      latitude: 37.78825,
      longitude: -122.4324,
      latitudeDelta: 0.01,
      longitudeDelta: 0.01,
    };

    const currentLocation = pickingLocationFor === 'start' ? startLocation : endLocation;

    return (
      <View style={styles.mapContainer}>
        <MapView
          style={styles.map}
          initialRegion={defaultRegion}
          onPress={(e) => {
            if (pickingLocationFor === 'start') {
              setStartLocation(e.nativeEvent.coordinate);
            } else {
              setEndLocation(e.nativeEvent.coordinate);
            }
          }}
        >
          {startLocation && (
            <Marker coordinate={startLocation} pinColor="#8ec07c" title="Start" />
          )}
          {endLocation && (
            <Marker coordinate={endLocation} pinColor="#fb4934" title="End" />
          )}
        </MapView>
        <View style={styles.mapOverlay}>
          <TouchableOpacity
            style={styles.mapBackButton}
            onPress={() => setScreen(isEditing ? 'editTrail' : 'createTrail')}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
              <Ionicons name="arrow-back" size={20} color="#8ec07c" />
              <Text style={styles.backButton}>Back</Text>
            </View>
          </TouchableOpacity>
          <Text style={styles.mapInstructions}>
            {currentLocation
              ? `${pickingLocationFor === 'start' ? 'Start' : 'End'} location selected`
              : `Tap on the map to select ${pickingLocationFor === 'start' ? 'start' : 'end'} location`}
          </Text>
          {currentLocation && (
            <TouchableOpacity
              style={styles.button}
              onPress={() => setScreen(isEditing ? 'editTrail' : 'createTrail')}
            >
              <Text style={styles.buttonText}>Confirm Location</Text>
            </TouchableOpacity>
          )}
        </View>
        <StatusBar style="light" translucent backgroundColor="transparent" />
      </View>
    );
  }

  if (screen === 'createTrail') {
    const handleCreate = async () => {
      if (!trailName || !distance) {
        Alert.alert('Error', 'Please fill in all fields');
        return;
      }

      setLoading(true);
      try {
        const trailData: any = {
          name: trailName,
          distance: parseFloat(distance),
          difficulty,
          status: 'planned',
        };

        if (startLocation) {
          trailData.start_lat = startLocation.latitude;
          trailData.start_lng = startLocation.longitude;
        }
        if (endLocation) {
          trailData.end_lat = endLocation.latitude;
          trailData.end_lng = endLocation.longitude;
        }

        // Try online first if connected
        if (isOnline) {
          try {
            await api.createTrail(trailData);
            Alert.alert('Success', 'Trail created!');
          } catch (error) {
            // Online failed, store offline
            await storage.addPendingTrail(trailData);
            await loadPendingSync();
            Alert.alert('Saved Offline', 'Trail will be synced when online');
          }
        } else {
          // Offline mode, store directly
          await storage.addPendingTrail(trailData);
          await loadPendingSync();
          Alert.alert('Saved Offline', 'Trail will be synced when online');
        }

        setTrailName('');
        setDistance('');
        setDifficulty('easy');
        setStartLocation(null);
        setEndLocation(null);
        setScreen('home');
        setPage(1);
        loadTrails(1, false);
      } catch (error: any) {
        Alert.alert('Error', error.message || 'Failed to create trail');
      } finally {
        setLoading(false);
      }
    };

    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => setScreen('home')} style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="arrow-back" size={20} color="#8ec07c" />
            <Text style={styles.backButton}>Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>New Trail</Text>
          <View style={{ width: 50 }} />
        </View>

        <TextInput
          style={styles.input}
          placeholder="Trail Name"
          placeholderTextColor="#928374"
          value={trailName}
          onChangeText={setTrailName}
        />

        <TextInput
          style={styles.input}
          placeholder="Distance (km)"
          placeholderTextColor="#928374"
          value={distance}
          onChangeText={setDistance}
          keyboardType="numeric"
        />

        <Text style={styles.label}>Difficulty</Text>
        <View style={styles.difficultyButtons}>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'easy' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('easy')}
          >
            <Text style={styles.difficultyButtonText}>Easy</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'moderate' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('moderate')}
          >
            <Text style={styles.difficultyButtonText}>Moderate</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'hard' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('hard')}
          >
            <Text style={styles.difficultyButtonText}>Hard</Text>
          </TouchableOpacity>
        </View>

        <Text style={styles.label}>Locations</Text>
        <View style={styles.locationButtons}>
          <TouchableOpacity
            style={[styles.button, styles.secondaryButton, { flex: 1, marginRight: 8 }]}
            onPress={() => {
              setPickingLocationFor('start');
              setScreen('pickLocation');
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name={startLocation ? "checkmark-circle" : "location"} size={18} color="#282828" />
              <Text style={styles.buttonText}>Start</Text>
            </View>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.secondaryButton, { flex: 1 }]}
            onPress={() => {
              setPickingLocationFor('end');
              setScreen('pickLocation');
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name={endLocation ? "checkmark-circle" : "location"} size={18} color="#282828" />
              <Text style={styles.buttonText}>End</Text>
            </View>
          </TouchableOpacity>
        </View>

        <TouchableOpacity style={styles.button} onPress={handleCreate}>
          <Text style={styles.buttonText}>
            {loading ? 'Creating...' : 'Create Trail'}
          </Text>
        </TouchableOpacity>

        <StatusBar style="light" translucent backgroundColor="transparent" />
      </ScrollView>
    );
  }

  if (screen === 'editTrail' && selectedTrail) {
    const handleUpdate = async () => {
      if (!trailName || !distance) {
        Alert.alert('Error', 'Please fill in all fields');
        return;
      }

      setLoading(true);
      try {
        const trailData: any = {
          name: trailName,
          distance: parseFloat(distance),
          difficulty,
          status: selectedTrail.status || 'planned',
        };

        if (startLocation) {
          trailData.start_lat = startLocation.latitude;
          trailData.start_lng = startLocation.longitude;
        }
        if (endLocation) {
          trailData.end_lat = endLocation.latitude;
          trailData.end_lng = endLocation.longitude;
        }

        await api.updateTrail(selectedTrail.id, trailData);
        Alert.alert('Success', 'Trail updated!');

        // Update local trail
        const updatedTrail = { ...selectedTrail, ...trailData };
        setSelectedTrail(updatedTrail);

        setIsEditing(false);
        setTrailName('');
        setDistance('');
        setDifficulty('easy');
        setStartLocation(null);
        setEndLocation(null);
        setScreen('trailDetail');
        loadTrails(1, false);
      } catch (error: any) {
        Alert.alert('Error', error.message || 'Failed to update trail');
      } finally {
        setLoading(false);
      }
    };

    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity
            onPress={() => {
              setIsEditing(false);
              setTrailName('');
              setDistance('');
              setDifficulty('easy');
              setStartLocation(null);
              setEndLocation(null);
              setScreen('trailDetail');
            }}
            style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}
          >
            <Ionicons name="arrow-back" size={20} color="#8ec07c" />
            <Text style={styles.backButton}>Cancel</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Edit Trail</Text>
          <View style={{ width: 50 }} />
        </View>

        <TextInput
          style={styles.input}
          placeholder="Trail Name"
          placeholderTextColor="#928374"
          value={trailName}
          onChangeText={setTrailName}
        />

        <TextInput
          style={styles.input}
          placeholder="Distance (km)"
          placeholderTextColor="#928374"
          value={distance}
          onChangeText={setDistance}
          keyboardType="numeric"
        />

        <Text style={styles.label}>Difficulty</Text>
        <View style={styles.difficultyButtons}>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'easy' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('easy')}
          >
            <Text style={styles.difficultyButtonText}>Easy</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'moderate' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('moderate')}
          >
            <Text style={styles.difficultyButtonText}>Moderate</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.difficultyButton, difficulty === 'hard' && styles.difficultyButtonActive]}
            onPress={() => setDifficulty('hard')}
          >
            <Text style={styles.difficultyButtonText}>Hard</Text>
          </TouchableOpacity>
        </View>

        <Text style={styles.label}>Locations</Text>
        <View style={styles.locationButtons}>
          <TouchableOpacity
            style={[styles.button, styles.secondaryButton, { flex: 1, marginRight: 8 }]}
            onPress={() => {
              setPickingLocationFor('start');
              setScreen('pickLocation');
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name={startLocation ? "checkmark-circle" : "location"} size={18} color="#282828" />
              <Text style={styles.buttonText}>Start</Text>
            </View>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.secondaryButton, { flex: 1 }]}
            onPress={() => {
              setPickingLocationFor('end');
              setScreen('pickLocation');
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name={endLocation ? "checkmark-circle" : "location"} size={18} color="#282828" />
              <Text style={styles.buttonText}>End</Text>
            </View>
          </TouchableOpacity>
        </View>

        <TouchableOpacity style={styles.button} onPress={handleUpdate}>
          <Text style={styles.buttonText}>
            {loading ? 'Updating...' : 'Save Changes'}
          </Text>
        </TouchableOpacity>

        <StatusBar style="light" translucent backgroundColor="transparent" />
      </ScrollView>
    );
  }

  if (screen === 'trailDetail' && selectedTrail) {
    const currentTrailPhotos = trailPhotos[selectedTrail.id] || [];

    return (
      <ScrollView style={styles.container} contentContainerStyle={{ paddingBottom: 24 + insets.bottom }}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => setScreen('home')} style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <Ionicons name="arrow-back" size={20} color="#8ec07c" />
            <Text style={styles.backButton}>Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Trail Details</Text>
          <View style={{ width: 50 }} />
        </View>

        <View style={styles.detailCard}>
          <Text style={styles.detailName}>{selectedTrail.name}</Text>

          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Distance:</Text>
            <Text style={styles.detailValue}>{selectedTrail.distance} km</Text>
          </View>

          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Difficulty:</Text>
            <Text style={styles.detailValue}>{selectedTrail.difficulty}</Text>
          </View>

          <View style={styles.detailRow}>
            <Text style={styles.detailLabel}>Status:</Text>
            <Text style={styles.detailValue}>{selectedTrail.status || 'planned'}</Text>
          </View>

          {selectedTrail.description && (
            <View style={styles.detailSection}>
              <Text style={styles.detailLabel}>Description:</Text>
              <Text style={styles.detailDescription}>{selectedTrail.description}</Text>
            </View>
          )}

          {selectedTrail.elevation_gain > 0 && (
            <View style={styles.detailRow}>
              <Text style={styles.detailLabel}>Elevation Gain:</Text>
              <Text style={styles.detailValue}>{selectedTrail.elevation_gain} m</Text>
            </View>
          )}
        </View>

        {selectedTrail.start_lat && selectedTrail.start_lng ? (
          <View style={styles.mapPreview}>
            <Text style={styles.label}>Trail Map</Text>
            <MapView
              style={styles.mapPreviewMap}
              initialRegion={{
                latitude: parseFloat(selectedTrail.start_lat),
                longitude: parseFloat(selectedTrail.start_lng),
                latitudeDelta: 0.02,
                longitudeDelta: 0.02,
              }}
              scrollEnabled={false}
              zoomEnabled={false}
            >
              <Marker
                coordinate={{
                  latitude: parseFloat(selectedTrail.start_lat),
                  longitude: parseFloat(selectedTrail.start_lng),
                }}
                pinColor="#8ec07c"
                title="Start"
              />
              {selectedTrail.end_lat && selectedTrail.end_lng && (
                <Marker
                  coordinate={{
                    latitude: parseFloat(selectedTrail.end_lat),
                    longitude: parseFloat(selectedTrail.end_lng),
                  }}
                  pinColor="#fb4934"
                  title="End"
                />
              )}
            </MapView>
          </View>
        ) : (
          <View style={styles.detailCard}>
            <Text style={styles.detailLabel}>No location set for this trail</Text>
          </View>
        )}

        <View style={styles.trailActions}>
          <TouchableOpacity
            style={[styles.button, { flex: 1, marginRight: 8 }]}
            onPress={() => {
              setIsEditing(true);
              setTrailName(selectedTrail.name);
              setDistance(selectedTrail.distance.toString());
              setDifficulty(selectedTrail.difficulty || 'easy');
              setStartLocation(
                selectedTrail.start_lat && selectedTrail.start_lng
                  ? { latitude: parseFloat(selectedTrail.start_lat), longitude: parseFloat(selectedTrail.start_lng) }
                  : null
              );
              setEndLocation(
                selectedTrail.end_lat && selectedTrail.end_lng
                  ? { latitude: parseFloat(selectedTrail.end_lat), longitude: parseFloat(selectedTrail.end_lng) }
                  : null
              );
              setScreen('editTrail');
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name="create-outline" size={18} color="#282828" />
              <Text style={styles.buttonText}>Edit</Text>
            </View>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.button, styles.deleteButton, { flex: 1 }]}
            onPress={() => {
              Alert.alert(
                'Delete Trail',
                'Are you sure you want to delete this trail?',
                [
                  { text: 'Cancel', style: 'cancel' },
                  {
                    text: 'Delete',
                    style: 'destructive',
                    onPress: async () => {
                      try {
                        await api.deleteTrail(selectedTrail.id);
                        database.deleteTrail(selectedTrail.id);
                        Alert.alert('Success', 'Trail deleted!');
                        setScreen('home');
                        loadTrails(1, false);
                      } catch (error) {
                        Alert.alert('Error', 'Failed to delete trail');
                      }
                    },
                  },
                ]
              );
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
              <Ionicons name="trash-outline" size={18} color="#282828" />
              <Text style={styles.buttonText}>Delete</Text>
            </View>
          </TouchableOpacity>
        </View>

        <TouchableOpacity
          style={styles.button}
          onPress={() => setScreen('camera')}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
            <Ionicons name="camera-outline" size={20} color="#282828" />
            <Text style={styles.buttonText}>Take Photo</Text>
          </View>
        </TouchableOpacity>

        {(() => {
          const trailPendingPhotos = pendingPhotos.filter(p => p.trailId === selectedTrail.id);
          const totalPhotos = serverPhotos.length + trailPendingPhotos.length;
          if (totalPhotos === 0) return null;
          return (
            <View style={styles.photosSection}>
              <Text style={styles.label}>Photos ({totalPhotos})</Text>
              <ScrollView horizontal showsHorizontalScrollIndicator={false}>
                {trailPendingPhotos.map((photo, index) => (
                  <View key={`pending-${photo.tempId}`} style={{ position: 'relative' }}>
                    <Image
                      source={{ uri: photo.photoUri }}
                      style={[styles.photoThumbnail, { borderWidth: 2, borderColor: '#d79921' }]}
                    />
                    <View style={{ position: 'absolute', top: 4, right: 20, backgroundColor: '#d79921', borderRadius: 8, padding: 4 }}>
                      <Ionicons name="cloud-upload-outline" size={12} color="#282828" />
                    </View>
                  </View>
                ))}
                {serverPhotos.map((photo, index) => (
                  <TouchableOpacity
                    key={photo.id || index}
                    onLongPress={() => {
                      Alert.alert(
                        'Save Photo',
                        'Save this photo to your gallery?',
                        [
                          { text: 'Cancel', style: 'cancel' },
                          {
                            text: 'Save',
                            onPress: async () => {
                              try {
                                const { status } = await MediaLibrary.requestPermissionsAsync();
                                if (status !== 'granted') {
                                  Alert.alert('Permission Required', 'Please grant media library permission to save photos');
                                  return;
                                }
                                // Download to local file first
                                const filename = photo.filename || `photo_${Date.now()}.jpg`;
                                const localUri = `${FileSystem.cacheDirectory}${filename}`;
                                await FileSystem.downloadAsync(api.getPhotoUrl(photo.server_url), localUri);
                                await MediaLibrary.saveToLibraryAsync(localUri);
                                Alert.alert('Success', 'Photo saved to gallery!');
                              } catch (error) {
                                console.error('Failed to save photo:', error);
                                Alert.alert('Error', 'Failed to save photo to gallery');
                              }
                            },
                          },
                        ]
                      );
                    }}
                  >
                    <Image
                      source={{ uri: api.getPhotoUrl(photo.server_url) }}
                      style={styles.photoThumbnail}
                    />
                  </TouchableOpacity>
                ))}
              </ScrollView>
            </View>
          );
        })()}

        <StatusBar style="light" translucent backgroundColor="transparent" />
      </ScrollView>
    );
  }

  if (screen === 'home') {
    return (
      <Animated.View style={[styles.container, { opacity: fadeAnim, paddingBottom: insets.bottom }]}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.logoutIconButton} onPress={handleLogout}>
            <Ionicons name="log-out-outline" size={22} color="#fb4934" />
          </TouchableOpacity>
          <Text style={styles.title}>My Trails</Text>
          <View style={[styles.networkStatus, isOnline ? styles.networkOnline : styles.networkOffline]}>
            <Ionicons name={isOnline ? "wifi" : "wifi-outline"} size={16} color="#fbf1c7" />
          </View>
        </View>

        {pendingSync.length > 0 && (
          <View style={styles.syncBanner}>
            <Text style={styles.syncBannerText}>
              {pendingSync.length} trail{pendingSync.length > 1 ? 's' : ''} pending sync
            </Text>
            {isOnline && (
              <TouchableOpacity onPress={syncPendingTrails}>
                <Text style={styles.syncBannerButton}>Sync Now</Text>
              </TouchableOpacity>
            )}
          </View>
        )}

        <TextInput
          style={styles.input}
          placeholder="Search trails..."
          placeholderTextColor="#928374"
          value={searchQuery}
          onChangeText={setSearchQuery}
        />

        <View style={styles.filterContainer}>
          <TouchableOpacity
            style={[styles.filterButton, filterDifficulty === '' && styles.filterButtonActive]}
            onPress={() => setFilterDifficulty('')}
          >
            <Text style={styles.filterButtonText}>All</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, filterDifficulty === 'easy' && styles.filterButtonActive]}
            onPress={() => setFilterDifficulty('easy')}
          >
            <Text style={styles.filterButtonText}>Easy</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, filterDifficulty === 'moderate' && styles.filterButtonActive]}
            onPress={() => setFilterDifficulty('moderate')}
          >
            <Text style={styles.filterButtonText}>Moderate</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.filterButton, filterDifficulty === 'hard' && styles.filterButtonActive]}
            onPress={() => setFilterDifficulty('hard')}
          >
            <Text style={styles.filterButtonText}>Hard</Text>
          </TouchableOpacity>
        </View>

        {trails.length === 0 && pendingSync.length === 0 ? (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyText}>No trails yet</Text>
            <Text style={styles.subtitle}>Create your first trail!</Text>
          </View>
        ) : (
          <FlatList
            data={[
              ...pendingSync.map(t => ({ ...t, id: `pending-${t.tempId}`, isPending: true })),
              ...trails
            ]}
            keyExtractor={(item: any) => item.id.toString()}
            renderItem={({ item, index }: any) => (
              <AnimatedTrailCard
                item={item}
                index={index}
                onPress={() => {
                  if (!item.isPending) {
                    setSelectedTrail(item);
                    setScreen('trailDetail');
                  }
                }}
              />
            )}
            style={styles.list}
            onEndReached={() => {
              if (hasMore && !loadingMore) {
                loadMoreTrails();
              }
            }}
            onEndReachedThreshold={0.5}
            ListFooterComponent={
              loadingMore ? (
                <View style={styles.loadingFooter}>
                  <Animated.View style={{
                    transform: [{
                      rotate: spinAnim.interpolate({
                        inputRange: [0, 1],
                        outputRange: ['0deg', '360deg'],
                      })
                    }]
                  }}>
                    <Ionicons name="sync" size={24} color="#8ec07c" />
                  </Animated.View>
                  <Text style={styles.loadingText}>Loading more...</Text>
                </View>
              ) : hasMore && trails.length >= 10 ? (
                <View style={styles.loadingFooter}>
                  <Text style={styles.loadingText}>Scroll to load more...</Text>
                </View>
              ) : null
            }
          />
        )}

        <TouchableOpacity style={[styles.fab, { bottom: 24 + insets.bottom }]} onPress={() => setScreen('createTrail')}>
          <Ionicons name="add" size={28} color="#282828" />
        </TouchableOpacity>

        <StatusBar style="light" translucent backgroundColor="transparent" />
      </Animated.View>
    );
  }

  return (
    <Animated.View style={{ flex: 1, opacity: fadeAnim }}>
      <ScrollView
        contentContainerStyle={styles.authContainer}
        keyboardShouldPersistTaps="handled"
      >
      <View style={styles.authHeader}>
        <View style={styles.logoContainer}>
          <Ionicons name="trail-sign" size={64} color="#8ec07c" />
        </View>
        <Text style={styles.authTitle}>HikeLog</Text>
        <Text style={styles.authSubtitle}>
          {isRegister ? 'Create your account' : 'Welcome back'}
        </Text>
      </View>

      <View style={styles.authForm}>
        {isRegister && (
          <View style={styles.inputContainer}>
            <Ionicons name="person-outline" size={20} color="#928374" style={styles.inputIcon} />
            <TextInput
              style={styles.authInput}
              placeholder="Username"
              placeholderTextColor="#928374"
              value={username}
              onChangeText={setUsername}
              autoCapitalize="none"
            />
          </View>
        )}

        <View style={styles.inputContainer}>
          <Ionicons name="mail-outline" size={20} color="#928374" style={styles.inputIcon} />
          <TextInput
            style={styles.authInput}
            placeholder="Email"
            placeholderTextColor="#928374"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            keyboardType="email-address"
          />
        </View>

        <View style={styles.inputContainer}>
          <Ionicons name="lock-closed-outline" size={20} color="#928374" style={styles.inputIcon} />
          <TextInput
            style={styles.authInput}
            placeholder="Password"
            placeholderTextColor="#928374"
            value={password}
            onChangeText={setPassword}
            secureTextEntry
          />
        </View>

        <TouchableOpacity
          style={styles.authButton}
          onPress={isRegister ? handleRegister : handleLogin}
          disabled={loading}
        >
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8, justifyContent: 'center' }}>
            {loading ? (
              <>
                <Ionicons name="sync" size={20} color="#282828" />
                <Text style={styles.authButtonText}>
                  {isRegister ? 'Creating account...' : 'Signing in...'}
                </Text>
              </>
            ) : (
              <>
                <Ionicons name={isRegister ? "person-add" : "log-in"} size={20} color="#282828" />
                <Text style={styles.authButtonText}>
                  {isRegister ? 'Sign Up' : 'Sign In'}
                </Text>
              </>
            )}
          </View>
        </TouchableOpacity>

        <View style={styles.divider}>
          <View style={styles.dividerLine} />
          <Text style={styles.dividerText}>or</Text>
          <View style={styles.dividerLine} />
        </View>

        <TouchableOpacity
          style={styles.switchButton}
          onPress={() => setIsRegister(!isRegister)}
        >
          <Text style={styles.switchButtonText}>
            {isRegister
              ? 'Already have an account? Sign In'
              : "Don't have an account? Sign Up"}
          </Text>
        </TouchableOpacity>
      </View>

      <StatusBar style="light" />
    </ScrollView>
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#282828',
    paddingHorizontal: 24,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingTop: 64,
    paddingBottom: 28,
  },
  title: {
    color: '#fbf1c7',
    fontSize: 28,
    fontWeight: '600',
    flex: 1,
    textAlign: 'center',
  },
  subtitle: {
    color: '#d5c4a1',
    fontSize: 16,
    marginBottom: 40,
    lineHeight: 24,
  },
  addButton: {
    backgroundColor: '#8ec07c',
    paddingHorizontal: 14,
    paddingVertical: 10,
    borderRadius: 12,
  },
  addButtonText: {
    color: '#282828',
    fontSize: 14,
    fontWeight: '600',
  },
  list: {
    flex: 1,
  },
  trailCard: {
    backgroundColor: '#3c3836',
    padding: 20,
    borderRadius: 16,
    marginBottom: 16,
  },
  trailCardPending: {
    borderWidth: 1,
    borderColor: '#d79921',
  },
  trailName: {
    color: '#fbf1c7',
    fontSize: 19,
    marginBottom: 8,
    fontWeight: '600',
  },
  trailInfo: {
    color: '#d5c4a1',
    fontSize: 15,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyText: {
    color: '#fbf1c7',
    fontSize: 18,
    marginBottom: 8,
  },
  form: {
    width: '100%',
    maxWidth: 400,
  },
  input: {
    backgroundColor: '#3c3836',
    borderWidth: 1,
    borderColor: '#504945',
    borderRadius: 12,
    paddingHorizontal: 20,
    paddingVertical: 16,
    color: '#fbf1c7',
    fontSize: 16,
    marginBottom: 20,
  },
  button: {
    backgroundColor: '#8ec07c',
    paddingVertical: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 12,
  },
  logoutButton: {
    backgroundColor: '#fb4934',
    marginTop: 16,
    marginBottom: 20,
  },
  deleteButton: {
    backgroundColor: '#fb4934',
  },
  loadMoreButton: {
    backgroundColor: '#458588',
    marginTop: 12,
    marginBottom: 12,
  },
  loadingFooter: {
    paddingVertical: 20,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingSpinner: {
    fontSize: 24,
    color: '#8ec07c',
    marginBottom: 8,
  },
  loadingText: {
    color: '#d5c4a1',
    fontSize: 14,
  },
  buttonText: {
    color: '#282828',
    fontSize: 16,
    fontWeight: '600',
  },
  linkButton: {
    marginTop: 20,
    alignItems: 'center',
  },
  linkText: {
    color: '#8ec07c',
    fontSize: 15,
  },
  centered: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  backButton: {
    color: '#8ec07c',
    fontSize: 16,
    fontWeight: '600',
  },
  label: {
    color: '#fbf1c7',
    fontSize: 16,
    marginBottom: 12,
    fontWeight: '600',
  },
  difficultyButtons: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 24,
  },
  difficultyButton: {
    flex: 1,
    backgroundColor: '#3c3836',
    paddingVertical: 14,
    borderRadius: 12,
    alignItems: 'center',
  },
  difficultyButtonActive: {
    backgroundColor: '#8ec07c',
  },
  difficultyButtonText: {
    color: '#fbf1c7',
    fontSize: 15,
    fontWeight: '600',
  },
  detailCard: {
    backgroundColor: '#3c3836',
    padding: 24,
    borderRadius: 16,
    marginBottom: 24,
  },
  detailName: {
    color: '#fbf1c7',
    fontSize: 26,
    marginBottom: 24,
    fontWeight: '600',
  },
  detailRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 16,
  },
  detailLabel: {
    color: '#d5c4a1',
    fontSize: 15,
  },
  detailValue: {
    color: '#fbf1c7',
    fontSize: 15,
    fontWeight: '600',
  },
  detailSection: {
    marginTop: 12,
  },
  detailDescription: {
    color: '#fbf1c7',
    fontSize: 15,
    marginTop: 12,
    lineHeight: 24,
  },
  cameraContainer: {
    flex: 1,
    backgroundColor: '#282828',
  },
  camera: {
    flex: 1,
  },
  cameraControls: {
    flex: 1,
    backgroundColor: 'transparent',
    justifyContent: 'flex-end',
    alignItems: 'center',
    paddingBottom: 50,
  },
  cameraButton: {
    width: 84,
    height: 84,
    borderRadius: 42,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  cameraButtonInner: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: '#fbf1c7',
  },
  cameraCloseButton: {
    position: 'absolute',
    top: 64,
    left: 28,
    backgroundColor: 'rgba(40, 40, 40, 0.85)',
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  photosSection: {
    marginTop: 28,
  },
  photoThumbnail: {
    width: 120,
    height: 120,
    borderRadius: 16,
    marginRight: 16,
    backgroundColor: '#3c3836',
  },
  secondaryButton: {
    backgroundColor: '#458588',
  },
  mapContainer: {
    flex: 1,
  },
  map: {
    flex: 1,
  },
  mapOverlay: {
    position: 'absolute',
    top: 60,
    left: 24,
    right: 24,
  },
  mapBackButton: {
    backgroundColor: 'rgba(40, 40, 40, 0.85)',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 12,
    alignSelf: 'flex-start',
  },
  mapInstructions: {
    backgroundColor: 'rgba(40, 40, 40, 0.9)',
    color: '#fbf1c7',
    fontSize: 15,
    textAlign: 'center',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderRadius: 12,
    marginTop: 16,
  },
  mapPreview: {
    marginBottom: 24,
  },
  mapPreviewMap: {
    height: 220,
    borderRadius: 16,
    marginTop: 12,
  },
  locationButtons: {
    flexDirection: 'row',
    marginBottom: 24,
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  networkStatus: {
    width: 40,
    height: 40,
    borderRadius: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  networkOnline: {
    backgroundColor: 'rgba(142, 192, 124, 0.25)',
  },
  networkOffline: {
    backgroundColor: 'rgba(251, 73, 52, 0.25)',
  },
  networkStatusText: {
    color: '#fbf1c7',
    fontSize: 13,
    fontWeight: '600',
  },
  logoutIconButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(251, 73, 52, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  filterContainer: {
    flexDirection: 'row',
    gap: 12,
    marginBottom: 20,
  },
  filterButton: {
    flex: 1,
    backgroundColor: '#3c3836',
    paddingVertical: 12,
    borderRadius: 12,
    alignItems: 'center',
  },
  filterButtonActive: {
    backgroundColor: '#458588',
  },
  filterButtonText: {
    color: '#fbf1c7',
    fontSize: 14,
    fontWeight: '600',
  },
  syncBanner: {
    backgroundColor: '#d79921',
    paddingVertical: 16,
    paddingHorizontal: 20,
    borderRadius: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  syncBannerText: {
    color: '#282828',
    fontSize: 15,
    fontWeight: '700',
  },
  syncBannerButton: {
    color: '#282828',
    fontSize: 15,
    fontWeight: '700',
    textDecorationLine: 'underline',
  },
  cameraFlipButton: {
    position: 'absolute',
    top: 64,
    right: 28,
    backgroundColor: 'rgba(40, 40, 40, 0.85)',
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
  },
  cameraFlipText: {
    fontSize: 24,
  },
  trailActions: {
    flexDirection: 'row',
    marginBottom: 16,
  },
  fab: {
    position: 'absolute',
    right: 24,
    bottom: 24,
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: '#8ec07c',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  authContainer: {
    flex: 1,
    backgroundColor: '#282828',
    paddingHorizontal: 32,
    paddingVertical: 60,
    justifyContent: 'center',
  },
  authHeader: {
    alignItems: 'center',
    marginBottom: 48,
  },
  logoContainer: {
    width: 96,
    height: 96,
    borderRadius: 48,
    backgroundColor: 'rgba(142, 192, 124, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 24,
  },
  authTitle: {
    color: '#fbf1c7',
    fontSize: 32,
    fontWeight: '700',
    marginBottom: 8,
  },
  authSubtitle: {
    color: '#d5c4a1',
    fontSize: 16,
    textAlign: 'center',
  },
  authForm: {
    width: '100%',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#3c3836',
    borderWidth: 1,
    borderColor: '#504945',
    borderRadius: 16,
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  inputIcon: {
    marginRight: 12,
  },
  authInput: {
    flex: 1,
    color: '#fbf1c7',
    fontSize: 16,
    paddingVertical: 18,
  },
  authButton: {
    backgroundColor: '#8ec07c',
    paddingVertical: 18,
    borderRadius: 16,
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 24,
  },
  authButtonText: {
    color: '#282828',
    fontSize: 17,
    fontWeight: '700',
  },
  divider: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 24,
  },
  dividerLine: {
    flex: 1,
    height: 1,
    backgroundColor: '#504945',
  },
  dividerText: {
    color: '#928374',
    fontSize: 14,
    marginHorizontal: 16,
  },
  switchButton: {
    paddingVertical: 16,
    alignItems: 'center',
  },
  switchButtonText: {
    color: '#8ec07c',
    fontSize: 15,
    fontWeight: '600',
  },
});

export default function App() {
  return (
    <SafeAreaProvider>
      <AppContent />
    </SafeAreaProvider>
  );
}
