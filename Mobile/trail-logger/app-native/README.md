# Trail Logger - Native Android App

Native Kotlin Android implementation of the Trail Logger app using Jetpack Compose and Clean Architecture.

## Features

- **JWT Authentication** - Secure login with token-based authentication
- **Trail List (Master View)** - Browse all trails with pull-to-refresh
- **Trail Detail/Edit (Detail View)** - View and edit trail information
- **Master-Detail UI Pattern** - Seamless navigation between list and details
- **REST API Integration** - Full integration with existing backend

## Architecture

### Clean Architecture (MVVM)
```
app-native/
├── data/              # Data layer
│   ├── remote/        # API services and DTOs
│   ├── local/         # DataStore for token storage
│   └── repository/    # Repository implementations
├── domain/            # Domain layer
│   ├── model/         # Domain models
│   ├── repository/    # Repository interfaces
│   └── usecase/       # Business logic use cases
└── presentation/      # Presentation layer (UI)
    ├── login/         # Login screen (3p)
    ├── trails/        # Trail list screen (3p)
    └── detail/        # Trail detail/edit screen (3p)
```

## Tech Stack

- **Language**: Kotlin
- **UI**: Jetpack Compose with Material 3
- **Architecture**: MVVM + Clean Architecture
- **DI**: Hilt (Dagger)
- **Networking**: Retrofit + OkHttp
- **JSON**: Kotlinx Serialization
- **Storage**: DataStore (JWT token)
- **Navigation**: Compose Navigation
- **Async**: Kotlin Coroutines + Flow

## API Integration

**Backend**: `https://hike-log-server-production.up.railway.app`

### Endpoints Used:
- `POST /auth/login` - User authentication
- `GET /api/trails` - Fetch all trails
- `GET /api/trail?id={id}` - Get trail details
- `PUT /api/trail?id={id}` - Update trail
- `DELETE /api/trail?id={id}` - Delete trail

## Building the App

### Prerequisites
- Android Studio Hedgehog (2023.1.1) or newer
- JDK 17
- Android SDK 34
- Gradle 8.2+

### Build Instructions

1. Open Android Studio
2. Select "Open an Existing Project"
3. Navigate to `trail-logger/` directory
4. Wait for Gradle sync to complete
5. Select a device or emulator (API 26+)
6. Click "Run" or press `Shift + F10`

### Build from Command Line

```bash
# Navigate to trail-logger directory
cd trail-logger

# Build debug APK
./gradlew assembleDebug

# Install on connected device
./gradlew installDebug

# Or build and install in one command
./gradlew installDebug
```

The APK will be generated at:
`app-native/build/outputs/apk/debug/app-native-debug.apk`

## Testing

### Test Credentials
Use any existing user from the backend, or create one via the Expo app first.

Example:
- Email: `test@example.com`
- Password: `your-password`

### Testing Flow

1. **Login (3p)**
   - Open app
   - Enter email and password
   - Click "Login"
   - Should navigate to trail list on success

2. **Trail List - Master View (3p)**
   - View all trails with name, distance, difficulty
   - Tap refresh icon to reload
   - Tap any trail to view details
   - Tap logout to sign out

3. **Trail Detail/Edit - Detail View (3p)**
   - View trail information
   - Tap edit icon to enter edit mode
   - Modify: name, description, difficulty, distance, elevation
   - Tap "Save Changes" to update
   - Tap "Cancel" to discard changes
   - Tap delete icon to remove trail (with confirmation)
   - Tap back arrow to return to list

## Project Requirements

✅ **Login page** (3p) - JWT authentication with email/password
✅ **List page** (3p) - Master view showing all trails
✅ **Edit page** (3p) - Detail view with edit capabilities
✅ **Master-detail UI** - Navigation between list and detail
✅ **REST service** - Full API integration with existing backend
✅ **JWT Authentication** - Token-based auth with secure storage

## Notes

- The app uses the same backend as the Expo app
- JWT tokens are stored securely in DataStore
- All API calls require authentication (except login)
- The app requires internet connectivity to function
- Min SDK: Android 8.0 (API 26)
- Target SDK: Android 14 (API 34)

## Troubleshooting

### Gradle Sync Issues
- Ensure JDK 17 is configured
- File → Project Structure → SDK Location → JDK Location

### Build Errors
- Clean project: Build → Clean Project
- Rebuild: Build → Rebuild Project
- Invalidate caches: File → Invalidate Caches / Restart

### Network Errors
- Check internet connectivity
- Backend server must be running
- Check Logcat for detailed error messages

## Future Enhancements

Potential features to add:
- Photo upload capability
- Map integration for trail locations
- Offline support with local database
- Search and filter functionality
- Pull-to-refresh on trail list
- Trail creation
