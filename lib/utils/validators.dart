// Form validation utilities
class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    // Add more password requirements as needed
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one letter and one number';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }
  
  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 8) {
      return 'Phone number must be at least 8 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number cannot exceed 15 digits';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // Number validation
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must be at most $max';
    }
    
    return null;
  }
  
  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }
  
  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    
    if (age < 0 || age > 150) {
      return 'Please enter a valid age between 0 and 150';
    }
    
    return null;
  }
  
  // License number validation (for doctors)
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    
    if (value.length < 5) {
      return 'License number must be at least 5 characters';
    }
    
    return null;
  }
  
  // Specialty validation
  static String? validateSpecialty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Specialty is required';
    }
    
    return null;
  }
  
  // Experience validation
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Experience is required';
    }
    
    final experience = int.tryParse(value);
    if (experience == null) {
      return 'Please enter a valid number of years';
    }
    
    if (experience < 0 || experience > 60) {
      return 'Experience must be between 0 and 60 years';
    }
    
    return null;
  }
  
  // Consultation fee validation
  static String? validateConsultationFee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Consultation fee is required';
    }
    
    final fee = double.tryParse(value);
    if (fee == null) {
      return 'Please enter a valid amount';
    }
    
    if (fee < 0) {
      return 'Consultation fee cannot be negative';
    }
    
    return null;
  }
  
  // Rating validation
  static String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }
    
    if (value < 1.0 || value > 5.0) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }
  
  // Review comment validation
  static String? validateReviewComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Review comment is required';
    }
    
    if (value.length < 10) {
      return 'Review must be at least 10 characters long';
    }
    
    if (value.length > 500) {
      return 'Review cannot exceed 500 characters';
    }
    
    return null;
  }
}
