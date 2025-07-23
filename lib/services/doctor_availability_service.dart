import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAvailabilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save doctor's availability for a specific date
  Future<bool> saveAvailability({
    required String doctorId,
    required String date, // YYYY-MM-DD format
    required Map<String, bool> timeSlots,
  }) async {
    try {
      final docId = '${doctorId}_$date';
      
      // Convert time slots to the format we want to store
      final Map<String, dynamic> availability = {
        'doctorId': doctorId,
        'date': date,
        'timeSlots': timeSlots,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('doctor_availability').doc(docId).set(availability);
      print('✅ Saved availability for doctor $doctorId on $date');
      return true;
    } catch (e) {
      print('❌ Error saving availability: $e');
      return false;
    }
  }

  // Get doctor's availability for a specific date
  Future<Map<String, bool>> getAvailability({
    required String doctorId,
    required String date,
  }) async {
    try {
      final docId = '${doctorId}_$date';
      final doc = await _firestore.collection('doctor_availability').doc(docId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final timeSlots = data['timeSlots'] as Map<String, dynamic>?;
        
        if (timeSlots != null) {
          // Convert to Map<String, bool>
          return timeSlots.map((key, value) => MapEntry(key, value as bool));
        }
      }
      
      // Return default availability if no data found
      return _getDefaultAvailability();
    } catch (e) {
      print('❌ Error getting availability: $e');
      return _getDefaultAvailability();
    }
  }

  // Check if a specific time slot is available for booking
  Future<bool> isTimeSlotAvailable({
    required String doctorId,
    required String date,
    required String timeSlot, // e.g., "10:00" (24-hour format)
  }) async {
    try {
      // Convert 24-hour to 12-hour format for checking
      final timeSlot12 = _convertTo12HourFormat(timeSlot);
      
      final availability = await getAvailability(doctorId: doctorId, date: date);
      
      // Check if the time slot is marked as available
      return availability[timeSlot12] ?? false;
    } catch (e) {
      print('❌ Error checking time slot availability: $e');
      return false;
    }
  }

  // Get all available time slots for a doctor on a specific date
  Future<List<String>> getAvailableTimeSlots({
    required String doctorId,
    required String date,
  }) async {
    try {
      final availability = await getAvailability(doctorId: doctorId, date: date);
      
      // Return only available slots
      return availability.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      print('❌ Error getting available time slots: $e');
      return [];
    }
  }

  // Get doctor's availability for multiple dates (for calendar view)
  Future<Map<String, Map<String, bool>>> getAvailabilityRange({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final Map<String, Map<String, bool>> result = {};
      
      // Query the range
      final query = await _firestore
          .collection('doctor_availability')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: _formatDate(startDate))
          .where('date', isLessThanOrEqualTo: _formatDate(endDate))
          .get();

      for (var doc in query.docs) {
        final data = doc.data();
        final date = data['date'] as String;
        final timeSlots = data['timeSlots'] as Map<String, dynamic>?;
        
        if (timeSlots != null) {
          result[date] = timeSlots.map((key, value) => MapEntry(key, value as bool));
        }
      }
      
      return result;
    } catch (e) {
      print('❌ Error getting availability range: $e');
      return {};
    }
  }

  // Helper method to get default availability (all slots available)
  Map<String, bool> _getDefaultAvailability() {
    return {
      '09:00 AM': true,
      '10:00 AM': true,
      '11:00 AM': true,
      '12:00 PM': true,
      '02:00 PM': true,
      '03:00 PM': true,
      '04:00 PM': true,
      '05:00 PM': true,
    };
  }

  // Convert 24-hour format to 12-hour format
  String _convertTo12HourFormat(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Block/unblock specific time slot
  Future<bool> toggleTimeSlotAvailability({
    required String doctorId,
    required String date,
    required String timeSlot,
  }) async {
    try {
      final currentAvailability = await getAvailability(doctorId: doctorId, date: date);
      
      // Toggle the specific time slot
      currentAvailability[timeSlot] = !(currentAvailability[timeSlot] ?? false);
      
      // Save the updated availability
      return await saveAvailability(
        doctorId: doctorId,
        date: date,
        timeSlots: currentAvailability,
      );
    } catch (e) {
      print('❌ Error toggling time slot availability: $e');
      return false;
    }
  }
}
