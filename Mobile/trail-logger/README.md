# HikeLog

Trail logging mobile application with offline support.

## Features

- User authentication (register/login)
- Create, view, edit, delete trails
- Set trail details: name, distance, difficulty, status
- Pick start/end locations on map
- Take and upload photos for trails
- Search trails by name
- Filter trails by difficulty
- Offline mode with local SQLite cache
- Pending data sync when back online
- Real-time notifications via WebSocket when trails are updated

## Tech Stack

**Mobile App**
- React Native / Expo
- TypeScript
- expo-sqlite for local caching
- expo-camera for photos
- react-native-maps for location picking

**Server**
- Go
- SQLite
- WebSocket for real-time updates
- JWT authentication

## Setup

### Server

```bash
cd server
go run .
```

Environment variables:
- `PORT` - Server port (default: 8080)
- `JWT_SECRET` - Secret for JWT tokens
- `DB_PATH` - SQLite database path
- `UPLOAD_DIR` - Photo upload directory

### App

1. Update `app/config.json` with server URL
2. Run:

```bash
cd app
npm install
npx expo prebuild
npx expo run:android
```

## Deployment

Server deployed on Railway: `https://hike-log-server-production.up.railway.app`
