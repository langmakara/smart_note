# Smart Notes

A beautiful and simple note-taking and to-do app built with Flutter.

## Prerequisites

Before running this project, make sure you have:

1. **Flutter SDK** (version 3.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (included with Flutter)

3. **IDE** (optional but recommended)
   - VS Code with Flutter extension
   - Android Studio with Flutter plugin

4. **Platform-specific requirements**
   - **iOS**: Xcode (for Mac users)
   - **Android**: Android SDK

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd smart_note
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code (if needed)
```bash
flutter pub run build_runner build
```

## Running the App

### Run on Android
```bash
flutter run
```

Or to run on a specific device:
```bash
flutter devices    # List available devices
flutter run -d <device-id>
```

### Run on iOS (Mac only)
```bash
flutter run -d ios
```

### Run on Web
```bash
flutter run -d chrome
```

### Run on Windows
```bash
flutter run -d windows
```

## Building APK

### Android Debug APK
```bash
flutter build apk --debug
```

### Android Release APK
```bash
flutter build apk --release
```

The APK will be in: `build/app/outputs/flutter-apk/`

### iOS (requires Mac)
```bash
flutter build ios
```

## Project Structure

```
smart_note/
├── lib/
│   ├── config/              # App configuration
│   ├── features/            # Feature modules
│   │   ├── auth/           # Authentication
│   │   ├── calender/       # Calendar feature
│   │   ├── home/           # Home screen
│   │   ├── notification/   # Notifications
│   │   └── settings/       # Settings
│   ├── models/             # Data models
│   ├── providers/          # State management
│   ├── repositories/       # Data repositories
│   ├── services/           # Business logic
│   └── main.dart           # Entry point
├── pubspec.yaml            # Dependencies
└── README.md               # This file
```

## Features

- ✅ Notes Management
- ✅ To-Do Management  
- ✅ Calendar with Events
- ✅ Event Reminders
- ✅ Dark Mode
- ✅ Custom Accent Colors
- ✅ Language Settings
- ✅ App Security (Password Lock)

## Dependencies

Key packages used:
- `provider` - State management
- `sqflite` - Local database
- `hive` / `hive_flutter` - NoSQL storage
- `flutter_local_notifications` - Push notifications
- `path_provider` - File system paths
- `file_picker` - File selection
- `uuid` - Unique ID generation
- `timezone` - Timezone handling

## Troubleshooting

### Flutter command not found
- Add Flutter to your system PATH
- Restart terminal

### Android SDK not found
- Install Android Studio
- Run: `flutter doctor --android-licenses`

### Build errors
- Try: `flutter clean`
- Then: `flutter pub get`

### Pod install failed (iOS)
- Run: `cd ios && pod install --repo-update`
