// App route definitions
class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String roleSelection = '/role-selection';
  
  // Patient routes
  static const String patientDashboard = '/patient-dashboard';
  static const String patientProfile = '/patient-profile';
  static const String patientCalendar = '/patient-calendar';
  static const String favorites = '/favorites';
  static const String availableSlots = '/available-slots';
  static const String writeReview = '/write-review';
  
  // Doctor routes
  static const String doctorDashboard = '/doctor_dashboard';
  static const String doctorProfile = '/doctor-profile';
  static const String doctorCalendar = '/doctor-calendar';
  static const String confirmAppointments = '/confirm-appointments';
  
  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String manageUsers = '/manage-users';
  static const String manageCalendar = '/manage-calendar';
  
  // Shared routes
  static const String doctorProfileView = '/doctor-profile-view';
  static const String availabilityCalendar = '/availability-calendar';
  static const String mapView = '/map-view';
  
  // Utils routes
  static const String databaseInitializer = '/database-initializer';
}
