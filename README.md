# 🩺 Tabibi - Medical Appointment Management System

A comprehensive Flutter-based medical appointment management application that connects patients with doctors through an intuitive booking system.

## 🎯 Project Overview

**Tabibi** is a modern healthcare appointment management platform built with Flutter and Firebase. The application facilitates seamless interactions between patients and doctors, offering features like appointment booking, calendar management, real-time availability tracking, and comprehensive user profiles.

### 🏗️ Architecture

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **State Management**: Provider Pattern
- **Platform Support**: Android, iOS, Web, Desktop

## ✨ Key Features

### 👥 Multi-User System
- **Patients**: Browse doctors, book appointments, manage schedules
- **Doctors**: Manage availability, view appointments, update profiles
- **Authentication**: Secure Firebase Auth with role-based access

### 📅 Smart Appointment System
- **Real-time Availability**: Doctors control their available time slots
- **Conflict Prevention**: System prevents double-bookings automatically
- **Dynamic Scheduling**: Time slots update based on doctor availability
- **Instant Notifications**: Real-time booking confirmations

### 🎨 Modern UI/UX
- **Responsive Design**: Adapts to different screen sizes
- **Intuitive Navigation**: Role-based dashboards and navigation
- **Material Design**: Clean, modern interface following Material 3 guidelines
- **Multilingual Support**: English and Arabic localization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Firebase CLI
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd tabibi_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in appropriate directories

4. **Set up Firestore Security Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Application Structure

### Core Directories

```
lib/
├── constants/          # App-wide constants (colors, routes, strings)
├── l10n/              # Internationalization files
├── models/            # Data models (User, Doctor, Patient, Appointment)
├── providers/         # State management (Provider pattern)
├── screens/           # UI screens organized by user role
│   ├── auth/          # Authentication screens
│   ├── doctor/        # Doctor-specific screens
│   ├── patient/       # Patient-specific screens
│   └── shared/        # Shared UI components
├── services/          # Business logic and API services
├── utils/             # Utility functions and helpers
├── widgets/           # Reusable UI components
└── main.dart          # Application entry point
```

### Key Models

#### User Management
- **User**: Base user model with role-based permissions
- **Doctor**: Extended model with specialty, ratings, schedule
- **Patient**: Extended model with medical history, preferences

#### Appointment System
- **Appointment**: Core appointment model with status tracking
- **DoctorAvailability**: Time slot availability management
- **Review**: Patient feedback and rating system

### State Management

The application uses the Provider pattern for state management:

- **AuthProvider**: Handles user authentication state
- **UserProvider**: Manages current user data and profile
- **AppointmentProvider**: Manages appointment CRUD operations

## 🔧 Core Services

### Authentication Service
```dart
// Handles user registration, login, and role-based access
class AuthService {
  // Firebase Auth integration
  // Role-based user creation
  // Session management
}
```

### Appointment Service
```dart
// Manages all appointment-related operations
class AppointmentService {
  // Create, read, update, delete appointments
  // Real-time appointment synchronization
  // Conflict resolution
}
```

### Doctor Availability Service
```dart
// Handles doctor schedule and availability
class DoctorAvailabilityService {
  // Save/load doctor availability
  // Check time slot availability
  // Prevent patient booking on unavailable slots
}
```

## 🎨 UI Components

### Responsive Design
- Adaptive layouts for different screen sizes
- Consistent color scheme and typography
- Material Design 3 components

### Key Screens

#### Patient Flow
1. **Welcome/Login**: User authentication
2. **Doctor Search**: Browse and filter doctors
3. **Appointment Booking**: Select date/time and book
4. **Patient Calendar**: View and manage appointments
5. **Profile Management**: Update personal information

#### Doctor Flow
1. **Doctor Dashboard**: Overview of appointments and stats
2. **Calendar Management**: Set availability and view bookings
3. **Appointment Confirmation**: Manage incoming requests
4. **Profile Update**: Maintain professional information

## 🔥 Firebase Configuration

### Firestore Collections

```javascript
// Users collection
users/{userId} {
  email: string,
  displayName: string,
  role: "patient" | "doctor",
  profilePicture: string,
  // role-specific fields
}

// Appointments collection
appointments/{appointmentId} {
  patientId: string,
  doctorId: string,
  appointmentDate: string,
  appointmentTime: string,
  status: "pending" | "confirmed" | "completed" | "cancelled",
  notes: string
}

// Doctor availability collection
doctor_availability/{doctorId}_{date} {
  doctorId: string,
  date: string,
  timeSlots: {
    "09:00 AM": boolean,
    "10:00 AM": boolean,
    // ... more time slots
  }
}
```

### Security Rules
- Role-based read/write permissions
- User can only access their own data
- Doctors can only modify their availability
- Patients can only book available slots

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

### Test Coverage
- Unit tests for services and providers
- Widget tests for UI components
- Integration tests for user flows

## 📦 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔧 Development Guidelines

### Code Style
- Follow Dart coding conventions
- Use meaningful variable and function names
- Add comments for complex business logic
- Maintain consistent file structure

### Git Workflow
- Use feature branches for new development
- Write descriptive commit messages
- Create pull requests for code review
- Maintain clean commit history

### Performance Optimization
- Implement lazy loading for large lists
- Use image caching for profile pictures
- Optimize Firestore queries with proper indexing
- Implement offline support where applicable

## 🐛 Troubleshooting

### Common Issues

1. **Firebase Connection Issues**
   - Verify google-services.json is properly configured
   - Check internet connectivity
   - Ensure Firebase project is active

2. **Authentication Problems**
   - Clear app data and try again
   - Check Firebase Auth configuration
   - Verify user roles are properly set

3. **Build Errors**
   - Run `flutter clean && flutter pub get`
   - Update Flutter SDK if needed
   - Check for dependency conflicts

## 🚀 Future Enhancements

- [ ] Push notifications for appointment reminders
- [ ] Video consultation integration
- [ ] Payment gateway integration
- [ ] Advanced search and filtering
- [ ] Medical records management
- [ ] Multi-clinic support
- [ ] Analytics dashboard

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For technical support or questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation and troubleshooting guide

---

**Built with ❤️ using Flutter and Firebase**

*A modern solution for healthcare appointment management*
