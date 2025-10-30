# Revolut Clone - Transaction Viewer

A mobile application that displays Revolut account transactions with offline support and real-time updates.

## Features

### Core Functionality
- **Authentication**: Secure login using Revolut OAuth 2.0 with JWT token management
- **Transaction Viewing**: Master-detail interface displaying list of transactions with detailed view
- **Real-time Updates**: WebSocket integration for live transaction notifications
- **Offline Support**: Full offline functionality with automatic synchronization
- **Custom Transactions**: Ability to create custom transactions that persist across sessions
- **Search**: Text-based search to filter transactions
- **Pagination**: Infinite scroll for efficient loading of large transaction lists

### Technical Requirements (Ionic1 & Ionic2)

#### Ionic1 Requirements
- ✅ Master-detail user interface
- ✅ REST service integration for data fetching
- ✅ WebSocket integration for server-side notifications
- ✅ Comprehensive feature documentation

#### Ionic2 Assessment Requirements (8 points)

1. **Network Status Display (1p)**
   - Visual indicator showing online/offline status
   - Real-time updates when network connectivity changes

2. **User Authentication (1p)**
   - Revolut OAuth 2.0 integration
   - JWT token stored in local storage
   - Auto-login for authenticated users
   - Logout functionality

3. **User-Linked Resources (1p)**
   - REST services return only user's transactions
   - WebSocket notifications filtered by user
   - Custom transactions linked to authenticated user

4. **Online/Offline Behavior (2p)**
   - Online mode: Prioritize REST API calls
   - Offline mode: Store data locally
   - Display sync status for pending transactions
   - Queue unsent operations

5. **Automatic Synchronization (1p)**
   - Auto-sync when connection is restored
   - Background upload of queued transactions
   - Conflict resolution handling

6. **Pagination (2p)**
   - Infinite scroll implementation
   - Server-side pagination
   - Efficient memory management

7. **Search & Filter (1p)**
   - Text-based search across transaction descriptions
   - Real-time filtering of results

## Architecture

### Frontend (Mobile App)
- **Framework**: Expo (React Native)
- **Language**: TypeScript
- **State Management**: React Context API
- **Local Storage**: AsyncStorage
- **Networking**: Axios (REST), Socket.io (WebSocket)
- **Network Detection**: @react-native-community/netinfo

### Backend (Go Server)
- **Framework**: Go with Gin
- **Authentication**: JWT tokens
- **Database**: SQLite for custom transactions
- **External API**: Revolut Open Banking API
- **Real-time**: WebSocket server (gorilla/websocket)

## Data Model

### Transaction Structure
```typescript
{
  id: string;                    // Unique identifier
  accountId: string;             // Revolut account ID
  amount: number;                // Transaction amount
  currency: string;              // Currency code (GBP, EUR, etc.)
  description: string;           // Merchant/description
  type: 'credit' | 'debit';      // Transaction type
  status: 'booked' | 'pending';  // Transaction status
  date: string;                  // ISO 8601 datetime
  source: 'revolut' | 'custom';  // Data source
  synced: boolean;               // Sync status (custom only)
}
```

## API Endpoints

### Authentication
- `POST /auth/login` - Initiate Revolut OAuth flow
- `GET /auth/callback` - Handle OAuth callback, return JWT
- `POST /auth/logout` - Invalidate user session

### Transactions (Secured)
- `GET /api/transactions?page=1&limit=20&search=text` - Fetch merged transactions
- `POST /api/transactions` - Create custom transaction
- `DELETE /api/transactions/:id` - Delete custom transaction

### Real-time
- `WS /ws` - WebSocket connection for live updates

## Setup Instructions

### Server Setup
```bash
cd server
go mod init revolut-clone-server
go mod tidy
go run main.go
```

### Mobile App Setup
```bash
cd app
npm install
npm start
```

## Environment Variables

### Server (.env)
```
REVOLUT_CLIENT_ID=your_client_id
REVOLUT_CLIENT_SECRET=your_client_secret
REVOLUT_REDIRECT_URI=http://localhost:8080/auth/callback
JWT_SECRET=your_jwt_secret
PORT=8080
DATABASE_PATH=./data/transactions.db
```

### App (.env)
```
API_BASE_URL=http://localhost:8080
WS_URL=ws://localhost:8080/ws
```

## Workflow

### Online Mode
1. User logs in via Revolut OAuth
2. App fetches transactions from server
3. Server merges Revolut API data + custom transactions
4. User can create new transactions → immediately sent to server
5. WebSocket updates notify all connected clients

### Offline Mode
1. App detects network loss
2. Displays cached transactions
3. User can create transactions → stored locally with `synced: false`
4. Search/filter works on cached data

### Back Online
1. App detects connection restored
2. Automatically syncs pending transactions
3. Updates sync status indicators
4. Re-establishes WebSocket connection

## Project Structure

```
expo-app/
├── app/                          # Mobile application
│   ├── src/
│   │   ├── screens/             # Screen components
│   │   │   ├── LoginScreen.tsx
│   │   │   ├── TransactionListScreen.tsx
│   │   │   ├── TransactionDetailScreen.tsx
│   │   │   └── AddTransactionScreen.tsx
│   │   ├── components/          # Reusable components
│   │   │   ├── TransactionCard.tsx
│   │   │   ├── NetworkStatus.tsx
│   │   │   ├── SearchBar.tsx
│   │   │   └── SyncIndicator.tsx
│   │   ├── services/            # Business logic
│   │   │   ├── api.ts          # REST client
│   │   │   ├── websocket.ts    # WebSocket client
│   │   │   ├── storage.ts      # AsyncStorage wrapper
│   │   │   └── auth.ts         # Authentication logic
│   │   ├── hooks/               # Custom React hooks
│   │   │   ├── useNetworkStatus.ts
│   │   │   ├── useTransactions.ts
│   │   │   └── useAuth.ts
│   │   ├── context/             # React Context providers
│   │   │   ├── AuthContext.tsx
│   │   │   └── TransactionContext.tsx
│   │   └── types/               # TypeScript definitions
│   │       └── index.ts
│   ├── App.tsx
│   └── package.json
│
└── server/                       # Go backend
    ├── handlers/                # HTTP handlers
    │   ├── auth.go
    │   ├── transactions.go
    │   └── websocket.go
    ├── middleware/              # HTTP middleware
    │   ├── jwt.go
    │   └── cors.go
    ├── revolut/                 # Revolut API client
    │   └── client.go
    ├── database/                # Database layer
    │   ├── models.go
    │   └── migrations.go
    ├── main.go
    └── go.mod
```

## Development Notes

- Revolut Open Banking API has a 4-request-per-24-hour limit
- Transaction history is limited to 90 days after 5 minutes from authorization
- Custom transactions are stored indefinitely in the server database
- WebSocket reconnection is handled automatically by the client
- All timestamps use ISO 8601 format

## License

MIT
