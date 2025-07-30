# 🩺 Tabibi - Medical Appointment Management System

**Tabibi** is a comprehensive, cross-platform medical appointment management system built with Flutter and Firebase. It provides a seamless interface for patients to find doctors, book appointments, and manage their medical records, while offering doctors a powerful platform to manage their schedules and patient information. The application supports both English and Arabic languages.

![App Screenshot](assets/in.png)

---

## 📜 Table of Contents

- [🩺 Tabibi - Medical Appointment Management System](#-tabibi---medical-appointment-management-system)
  - [📜 Table of Contents](#-table-of-contents)
  - [✨ Features](#-features)
  - [🛠️ Technical Stack](#️-technical-stack)
  - [🚀 Getting Started](#-getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
    - [Firebase Setup](#firebase-setup)
  - [⚙️ Project Setup](#️-project-setup)
    - [Localization](#localization)
    - [Running the App](#running-the-app)
  - [🔧 Usage](#-usage)
  - [🤔 Troubleshooting](#-troubleshooting)

---

## ✨ Features

- **Role-Based Access Control:** Separate interfaces and functionalities for Patients, Doctors, and Admins.
- **Secure Authentication:** Email/Password and social login using Firebase Authentication.
- **Appointment Booking:** Patients can view available slots and book appointments in real-time.
- **Calendar Management:** Doctors can manage their availability and view upcoming appointments.
- **Patient Profiles:** Patients can update their profile and view their appointment history.
- **Doctor Profiles:** Doctors can showcase their specialty, experience, and qualifications.
- **Real-time Notifications:** Push notifications for appointment confirmations, reminders, and cancellations using Firebase Messaging.
- **Localization:** Full support for English and Arabic (RTL).
- **Cross-Platform:** A single codebase for Android, iOS, and Web.

---

## 🛠️ Technical Stack

- **Frontend:** [Flutter](https://flutter.dev/)
- **Backend & Database:** [Firebase](https://firebase.google.com/)
  - [Firebase Authentication](https://firebase.google.com/docs/auth)
  - [Cloud Firestore](https://firebase.google.com/docs/firestore)
  - [Firebase Storage](https://firebase.google.com/docs/storage)
  - [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- **State Management:** [Provider](https://pub.dev/packages/provider)
- **Localization:** [flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) & [intl](https://pub.dev/packages/intl)
- **Notifications:** [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Location Services:** [geolocator](https://pub.dev/packages/geolocator), [geocoding](https://pub.dev/packages/geocoding)
- **Utilities:** [http](https://pub.dev/packages/http), [image_picker](https://pub.dev/packages/image_picker), [url_launcher](https://pub.dev/packages/url_launcher)

---

## 🚀 Getting Started

Follow these instructions to get the project up and running on your local machine.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.8.1 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- An IDE such as [Android Studio](https://developer.android.com/studio), [Xcode](https://developer.apple.com/xcode/), or [VS Code](https://code.visualstudio.com/).
- An **Android Emulator** set up through [Android Studio](https://developer.android.com/studio/run/managing-avds).
  - **Minimum API Level:** API 23 (Android 6.0, Marshmallow).
  - **Recommended API Level:** API 30 (Android 11.0) or higher for best performance and compatibility.
  - **System Image:** A Google Play system image is recommended to ensure compatibility with Firebase services.
  - **Performance:** Ensure hardware virtualization (VT-x, SVM) is enabled in your computer's BIOS for better emulator performance.

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/YoussefFrigui/Tabibi.git
    cd Tabibi
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

### Firebase Setup

1.  Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  Add an **Android** and **iOS** app to your Firebase project.
3.  **For Android:**
    -   Download the `google-services.json` file.
    -   Place it in the `android/app/` directory.
4.  **For iOS:**
    -   Download the `GoogleService-Info.plist` file.
    -   Place it in the `ios/Runner/` directory using Xcode.
5.  Enable the following Firebase services:
    -   **Authentication:** Enable Email/Password sign-in provider.
    -   **Cloud Firestore:** Create a database.
    -   **Storage:** Create a storage bucket.
    -   **Cloud Messaging**.

---

## ⚙️ Project Setup

### Localization

To update or add new translations:

1.  Edit the `.arb` files in the `lib/l10n/` directory.
2.  Regenerate the localization files by running:
    ```sh
    flutter gen-l10n
    ```

### Running the App

You can run the application on an emulator, a physical device, or a web browser.

-   **Run on Android:**
    ```sh
    flutter run -d android
    ```
-   **Run on iOS:**
    ```sh
    flutter run -d ios
    ```
-   **Run on Web:**
    ```sh
    flutter run -d chrome
    ```

---

## 🔧 Usage

Once the app is running, you can:

1.  **Register** as a new Patient or Doctor.
2.  **Login** to your account.
3.  If you are a **Patient**:
    -   Search for doctors by specialty.
    -   View doctor profiles and reviews.
    -   Book an available appointment slot.
    -   View and manage your upcoming appointments.
4.  If you are a **Doctor**:
    -   Set your availability in the calendar.
    -   View and confirm incoming appointment requests.
    -   Manage your patient list.

---
## 🤔 Troubleshooting

-   **Firebase related errors on run:**
    -   Ensure `google-services.json` and `GoogleService-Info.plist` are correctly placed.
    -   Check that the package names in your Firebase project match the ones in `android/app/build.gradle.kts` and your Xcode project.

-   **Build Fails / Missing Dependencies:**
    -   Run `flutter clean` followed by `flutter pub get`.

-   **Localization not updating:**
    -   Make sure you have run `flutter gen-l10n` after modifying the `.arb` files.
