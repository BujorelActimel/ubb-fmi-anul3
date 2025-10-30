# Implementation Guide - Remaining Frontend Files

## Summary of Completed Work

### ✅ Backend (Go Server) - COMPLETE
- Standard library implementation (minimal dependencies)
- JWT authentication (custom implementation)
- Revolut OAuth integration
- SQLite database for custom transactions
- WebSocket support for real-time updates
- Hybrid data source (Revolut API + custom transactions)
- Full REST API with pagination and search

### ✅ Frontend Setup - COMPLETE
- Expo app initialized with TypeScript
- Dependencies installed
- TypeScript types defined
- Storage service (AsyncStorage)
- API service with offline support

## Remaining Frontend Implementation

Continue with these steps to complete the mobile app:

### 1. WebSocket Service

Create `src/services/websocket.ts`:

```typescript
import io, { Socket } from 'socket.io-client';
import { getAuthToken } from './storage';
import { WebSocketMessage } from '../types';

class WebSocketService {
  private socket: Socket | null = null;
  private listeners: ((message: WebSocketMessage) => void)[] = [];

  async connect() {
    const token = await getAuthToken();
    if (!token) return;

    this.socket = io('ws://localhost:8080/ws', {
      query: { token },
      transports: ['websocket'],
    });

    this.socket.on('connect', () => {
      console.log('WebSocket connected');
    });

    this.socket.on('message', (data: WebSocketMessage) => {
      this.listeners.forEach(listener => listener(data));
    });

    this.socket.on('disconnect', () => {
      console.log('WebSocket disconnected');
    });
  }

  disconnect() {
    if (this.socket) {
      this.socket.disconnect();
      this.socket = null;
    }
  }

  addListener(listener: (message: WebSocketMessage) => void) {
    this.listeners.push(listener);
  }

  removeListener(listener: (message: WebSocketMessage) => void) {
    this.listeners = this.listeners.filter(l => l !== listener);
  }
}

export const wsService = new WebSocketService();
```

### 2. Network Status Hook

Create `src/hooks/useNetworkStatus.ts`:

```typescript
import { useEffect, useState } from 'react';
import NetInfo from '@react-native-community/netinfo';

export const useNetworkStatus = () => {
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsOnline(state.isConnected ?? false);
    });

    return () => unsubscribe();
  }, []);

  return isOnline;
};
```

### 3. Auth Context

Create `src/context/AuthContext.tsx`:

```typescript
import React, { createContext, useState, useEffect, useContext } from 'react';
import { getAuthToken, getUserID, saveUserID, clearAllData } from '../services/storage';
import { apiService } from '../services/api';

interface AuthContextType {
  isAuthenticated: boolean;
  userID: string | null;
  login: (code: string, state: string) => Promise<void>;
  logout: () => Promise<void>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [userID, setUserID] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    checkAuth();
  }, []);

  const checkAuth = async () => {
    const token = await getAuthToken();
    const savedUserID = await getUserID();
    setIsAuthenticated(!!token);
    setUserID(savedUserID);
    setLoading(false);
  };

  const login = async (code: string, state: string) => {
    const response = await apiService.handleCallback(code, state);
    await saveUserID(response.userId);
    setUserID(response.userId);
    setIsAuthenticated(true);
  };

  const logout = async () => {
    await apiService.logout();
    await clearAllData();
    setIsAuthenticated(false);
    setUserID(null);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, userID, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

### 4. Main Screens

The app requires these screens:
- `LoginScreen.tsx` - OAuth initiation
- `TransactionListScreen.tsx` - List with infinite scroll
- `TransactionDetailScreen.tsx` - Detail view
- `AddTransactionScreen.tsx` - Form to create transactions

### 5. Components

- `NetworkStatus.tsx` - Online/offline indicator
- `TransactionCard.tsx` - List item component
- `SearchBar.tsx` - Search input
- `SyncIndicator.tsx` - Shows unsynced count

### 6. App.tsx

Main app file with navigation and providers.

## Quick Start Commands

### Start Server:
```bash
cd server
cp .env.example .env
# Edit .env with your Revolut credentials
go run main.go
```

### Start Mobile App:
```bash
cd app
npm start
```

## Testing the App

1. Configure Revolut OAuth credentials in `server/.env`
2. Start the Go server: `go run main.go`
3. Start Expo: `npm start` in the app directory
4. Test login flow
5. Test creating transactions offline
6. Test sync when going back online

## Notes

- The server uses minimal dependencies (only sqlite3 and x/net/websocket)
- JWT is implemented from scratch using standard library
- OAuth flow may require adjusting redirect URI for mobile
- For production, use proper error handling and token refresh logic
