// Data formatting utilities
import 'package:intl/intl.dart';

class Formatters {
  // Date formatters
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _displayTimeFormat = DateFormat('h:mm a');
  static final DateFormat _displayDateTimeFormat = DateFormat('MMM dd, yyyy h:mm a');
  
  // Format date to string
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }
  
  // Format time to string
  static String formatTime(DateTime time) {
    return _timeFormat.format(time);
  }
  
  // Format datetime to string
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }
  
  // Format date for display
  static String formatDisplayDate(DateTime date) {
    return _displayDateFormat.format(date);
  }
  
  // Format time for display
  static String formatDisplayTime(DateTime time) {
    return _displayTimeFormat.format(time);
  }
  
  // Format datetime for display
  static String formatDisplayDateTime(DateTime dateTime) {
    return _displayDateTimeFormat.format(dateTime);
  }
  
  // Parse date string
  static DateTime? parseDate(String dateString) {
    try {
      return _dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  // Parse time string
  static DateTime? parseTime(String timeString) {
    try {
      return _timeFormat.parse(timeString);
    } catch (e) {
      return null;
    }
  }
  
  // Parse datetime string
  static DateTime? parseDateTime(String dateTimeString) {
    try {
      return _dateTimeFormat.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }
  
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }
  
  // Format phone number
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length == 10) {
      // Format as (XXX) XXX-XXXX
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      // Format as +1 (XXX) XXX-XXXX
      return '+1 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    } else {
      // Return as is if format is not recognized
      return phoneNumber;
    }
  }
  
  // Format name (capitalize first letter of each word)
  static String formatName(String name) {
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  // Format rating
  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }
  
  // Format duration in minutes to hours and minutes
  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours == 0) {
      return '${remainingMinutes}m';
    } else if (remainingMinutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${remainingMinutes}m';
    }
  }
  
  // Format file size
  static String formatFileSize(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(i == 0 ? 0 : 1)} ${suffixes[i]}';
  }
  
  // Format percentage
  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
  
  // Format experience years
  static String formatExperience(int years) {
    if (years == 0) {
      return 'Less than 1 year';
    } else if (years == 1) {
      return '1 year';
    } else {
      return '$years years';
    }
  }
  
  // Format appointment status
  static String formatAppointmentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'rescheduled':
        return 'Rescheduled';
      default:
        return status;
    }
  }
  
  // Format user role
  static String formatUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'Patient';
      case 'doctor':
        return 'Doctor';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }
  
  // Format relative time (e.g., "2 hours ago")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  // Format time range
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatDisplayTime(start)} - ${formatDisplayTime(end)}';
  }
  
  // Format address
  static String formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    
    if (address['street'] != null) parts.add(address['street']);
    if (address['city'] != null) parts.add(address['city']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['postalCode'] != null) parts.add(address['postalCode']);
    if (address['country'] != null) parts.add(address['country']);
    
    return parts.join(', ');
  }
}
