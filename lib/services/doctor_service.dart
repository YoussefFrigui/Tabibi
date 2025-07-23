import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all specialties
  Future<List<Map<String, dynamic>>> getSpecialties() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('specialties')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting specialties: $e');
      return [];
    }
  }

  // Search doctors with filters
  Future<List<Map<String, dynamic>>> searchDoctors({
    String? specialty,
    String? searchQuery,
    double? minRating,
    double? maxFee,
    bool? isVerified,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('isActive', isEqualTo: true);

      if (specialty != null && specialty.isNotEmpty) {
        query = query.where('specialty', isEqualTo: specialty);
      }

      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> doctors = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();

      // Apply client-side filters
      if (searchQuery != null && searchQuery.isNotEmpty) {
        doctors = doctors.where((doctor) {
          String name = doctor['displayName']?.toString().toLowerCase() ?? '';
          String specialty = doctor['specialty']?.toString().toLowerCase() ?? '';
          String query = searchQuery.toLowerCase();
          return name.contains(query) || specialty.contains(query);
        }).toList();
      }

      if (minRating != null) {
        doctors = doctors
            .where((doctor) => (doctor['rating'] ?? 0.0) >= minRating)
            .toList();
      }

      if (maxFee != null) {
        doctors = doctors
            .where((doctor) => (doctor['consultationFee'] ?? 0.0) <= maxFee)
            .toList();
      }

      // Sort by rating (highest first)
      doctors.sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));

      return doctors;
    } catch (e) {
      print('Error searching doctors: $e');
      return [];
    }
  }

  // Get doctor details by ID
  Future<Map<String, dynamic>?> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(doctorId).get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      print('Error getting doctor details: $e');
      return null;
    }
  }

  // Get doctor availability for a specific date
  Future<List<Map<String, dynamic>>> getDoctorAvailability(
    String doctorId,
    DateTime date,
  ) async {
    try {
      String dateKey = '${doctorId}_${_formatDate(date)}';

      DocumentSnapshot doc = await _firestore
          .collection('doctor_availability')
          .doc(dateKey)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<dynamic> slots = data['slots'] ?? [];
        
        return slots
            .map((slot) => Map<String, dynamic>.from(slot))
            .where((slot) => slot['isAvailable'] == true)
            .toList();
      }

      // If no specific availability found, generate default slots
      return await _generateDefaultAvailability(doctorId, date);
    } catch (e) {
      print('Error getting doctor availability: $e');
      return [];
    }
  }

  // Generate default availability based on doctor's general schedule
  Future<List<Map<String, dynamic>>> _generateDefaultAvailability(
    String doctorId,
    DateTime date,
  ) async {
    try {
      DocumentSnapshot doctorDoc =
          await _firestore.collection('users').doc(doctorId).get();

      if (!doctorDoc.exists) return [];

      Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> availability = doctorData['availability'] ?? {};

      String dayName = _getDayName(date.weekday);
      Map<String, dynamic> daySchedule = availability[dayName] ?? {};

      if (daySchedule['isAvailable'] != true) return [];

      String startTime = daySchedule['start'] ?? '09:00';
      String endTime = daySchedule['end'] ?? '17:00';

      return _generateTimeSlots(startTime, endTime);
    } catch (e) {
      print('Error generating default availability: $e');
      return [];
    }
  }

  // Set doctor availability for a specific date
  Future<bool> setDoctorAvailability(
    String doctorId,
    DateTime date,
    List<Map<String, dynamic>> slots,
  ) async {
    try {
      String dateKey = '${doctorId}_${_formatDate(date)}';

      await _firestore.collection('doctor_availability').doc(dateKey).set({
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'slots': slots,
        'isHoliday': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error setting doctor availability: $e');
      return false;
    }
  }

  // Update doctor profile
  Future<bool> updateDoctorProfile(Map<String, dynamic> profileData) async {
    try {
      String? doctorId = _auth.currentUser?.uid;
      if (doctorId == null) return false;

      await _firestore.collection('users').doc(doctorId).update({
        ...profileData,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating doctor profile: $e');
      return false;
    }
  }

  // Get doctor reviews
  Future<List<Map<String, dynamic>>> getDoctorReviews(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting doctor reviews: $e');
      return [];
    }
  }

  // Get doctor statistics
  Future<Map<String, dynamic>> getDoctorStats(String doctorId) async {
    try {
      // Get appointments count
      QuerySnapshot appointmentsSnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      int totalAppointments = appointmentsSnapshot.docs.length;
      int completedAppointments = appointmentsSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['status'] == 'completed')
          .length;

      // Get reviews
      List<Map<String, dynamic>> reviews = await getDoctorReviews(doctorId);
      
      double averageRating = 0.0;
      if (reviews.isNotEmpty) {
        double totalRating = reviews.fold(0.0, (sum, review) => sum + (review['rating'] ?? 0.0));
        averageRating = totalRating / reviews.length;
      }

      return {
        'totalAppointments': totalAppointments,
        'completedAppointments': completedAppointments,
        'totalReviews': reviews.length,
        'averageRating': averageRating,
      };
    } catch (e) {
      print('Error getting doctor stats: $e');
      return {
        'totalAppointments': 0,
        'completedAppointments': 0,
        'totalReviews': 0,
        'averageRating': 0.0,
      };
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'monday';
      case 2:
        return 'tuesday';
      case 3:
        return 'wednesday';
      case 4:
        return 'thursday';
      case 5:
        return 'friday';
      case 6:
        return 'saturday';
      case 7:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  List<Map<String, dynamic>> _generateTimeSlots(String startTime, String endTime) {
    List<Map<String, dynamic>> slots = [];
    
    // Parse start and end times
    List<String> startParts = startTime.split(':');
    List<String> endParts = endTime.split(':');
    
    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);
    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);
    
    DateTime current = DateTime(2024, 1, 1, startHour, startMinute);
    DateTime end = DateTime(2024, 1, 1, endHour, endMinute);
    
    while (current.isBefore(end)) {
      DateTime slotEnd = current.add(Duration(minutes: 30));
      if (slotEnd.isAfter(end)) break;
      
      String startTimeStr = '${current.hour.toString().padLeft(2, '0')}:${current.minute.toString().padLeft(2, '0')}';
      String endTimeStr = '${slotEnd.hour.toString().padLeft(2, '0')}:${slotEnd.minute.toString().padLeft(2, '0')}';
      
      slots.add({
        'startTime': startTimeStr,
        'endTime': endTimeStr,
        'isAvailable': true,
      });
      
      current = slotEnd;
    }
    
    return slots;
  }
}
