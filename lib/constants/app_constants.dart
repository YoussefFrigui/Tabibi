// General app constants
class AppConstants {
  // App version
  static const String version = '1.0.0';
  
  // API configuration
  static const String baseUrl = 'https://api.tabibi.com';
  static const int timeoutDuration = 30000; // 30 seconds
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];
  
  // Appointment
  static const int defaultAppointmentDuration = 30; // minutes
  static const int maxAppointmentDuration = 120; // minutes
  static const int minAppointmentDuration = 15; // minutes
  
  // Rating
  static const int minRating = 1;
  static const int maxRating = 5;
  
  // Search
  static const int minSearchLength = 3;
  static const int maxSearchResults = 50;
  
  // Cache
  static const int cacheExpiration = 24 * 60 * 60; // 24 hours in seconds
  
  // Animation
  static const int animationDuration = 300; // milliseconds
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  
  // Specialties
  static const List<String> medicalSpecialties = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Neurology',
    'Psychiatry',
    'Gynecology',
    'Ophthalmology',
    'ENT',
    'Dentistry',
    'Radiology',
    'Anesthesiology',
    'Surgery',
    'Emergency Medicine',
  ];
  
  // Working hours
  static const String defaultStartTime = '09:00';
  static const String defaultEndTime = '17:00';
  static const String defaultBreakTime = '12:00-13:00';
  
  // Notification types
  static const String appointmentReminder = 'appointment_reminder';
  static const String appointmentConfirmation = 'appointment_confirmation';
  static const String appointmentCancellation = 'appointment_cancellation';
  static const String appointmentRescheduledNotification = 'appointment_rescheduled';
  static const String newMessage = 'new_message';
  static const String reviewReceived = 'review_received';
  
  // User roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';
  static const String roleAdmin = 'admin';
  
  // Appointment statuses
  static const String appointmentPending = 'pending';
  static const String appointmentConfirmed = 'confirmed';
  static const String appointmentCompleted = 'completed';
  static const String appointmentCancelled = 'cancelled';
  static const String appointmentRescheduled = 'rescheduled';
  
  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'settings';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  
  // Supported languages
  static const List<String> supportedLanguages = ['en', 'fr', 'ar'];
  static const String defaultLanguage = 'en';
  
  // Map configuration
  static const double defaultLatitude = 33.8869;
  static const double defaultLongitude = 9.5375;
  static const double defaultZoom = 10.0;
  static const double searchRadius = 50.0; // km
}
