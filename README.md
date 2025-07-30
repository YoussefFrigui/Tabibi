
# 🩺 Tabibi - Medical Appointment Management System

Tabibi is a modern Flutter and Firebase-based application for managing medical appointments. It connects patients and doctors through a simple, intuitive booking system, supporting real-time scheduling, role-based access, and a clean, responsive UI.


**Key Features:**
- Book and manage appointments
- Doctor and patient user roles
- Real-time availability and notifications
- Secure authentication


---

## 🚀 Installation & Running

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.8.0 or higher recommended)
- [Dart SDK](https://dart.dev/get-dart)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for setup and emulators)
- Android Studio, Xcode, or VS Code (for running on emulator/device)
- A configured Firebase project (see below)

### 1. Clone the repository
```sh
git clone <repo-url>
cd tabibi_1
```

### 2. Install dependencies
```sh
flutter pub get
```

### 3. Configure Firebase
- Add your `google-services.json` (Android) to `android/app/`.
- Add your `GoogleService-Info.plist` (iOS) to `ios/Runner/`.
- Make sure Firebase is set up for Auth, Firestore, Storage, and Messaging.

### 4. Localization (Optional)
- To update or add translations, edit the ARB files in `lib/l10n/` and run:
  ```sh
  flutter gen-l10n
  ```

### 5. Run the app
- For Android:
  ```sh
  flutter run -d android
  ```
- For iOS:
  ```sh
  flutter run -d ios
  ```
- For Web:
  ```sh
  flutter run -d chrome
  ```

---

## 📁 Project Structure
- `lib/` — Main Dart codebase
- `lib/screens/` — UI screens for patients, doctors, auth, etc.
- `lib/models/` — Data models
- `lib/services/` — Firebase and business logic
- `lib/l10n/` — Localization files (English/Arabic)
- `lib/constants/` — App-wide constants
- `assets/` — Images and static assets

## 🛠️ Useful Commands
- Analyze code: `flutter analyze`
- Format code: `flutter format .`
- Run tests: `flutter test`



---


