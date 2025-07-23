import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get doctor's availability for a specific date
  Future<Map<String, dynamic>?> getDoctorAvailability(String doctorId, DateTime date) async {
    try {
      String dateString = _formatDate(date);
      
      DocumentSnapshot doc = await _firestore
          .collection('availability')
          .doc('${doctorId}_$dateString')
          .get();

      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }

      return null;
    } catch (e) {
      print('Error getting doctor availability: $e');
      return null;
    }
  }

  // Set doctor's availability for a specific date
  Future<bool> setDoctorAvailability({
    required String doctorId,
    required DateTime date,
    required List<Map<String, dynamic>> timeSlots,
    bool isAvailable = true,
  }) async {
    try {
      String dateString = _formatDate(date);
      
      await _firestore
          .collection('availability')
          .doc('${doctorId}_$dateString')
          .set({
        'doctorId': doctorId,
        'date': Timestamp.fromDate(date),
        'dateString': dateString,
        'isAvailable': isAvailable,
        'timeSlots': timeSlots,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error setting doctor availability: $e');
      return false;
    }
  }

  // Get doctor's availability for a date range
  Future<Map<String, Map<String, dynamic>>> getDoctorAvailabilityRange(
    String doctorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('availability')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      Map<String, Map<String, dynamic>> availabilityMap = {};

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String dateString = data['dateString'];
        availabilityMap[dateString] = {
          'id': doc.id,
          ...data,
        };
      }

      return availabilityMap;
    } catch (e) {
      print('Error getting doctor availability range: $e');
      return {};
    }
  }

  // Get available time slots for a doctor on a specific date
  Future<List<Map<String, dynamic>>> getAvailableTimeSlots(String doctorId, DateTime date) async {
    try {
      Map<String, dynamic>? availability = await getDoctorAvailability(doctorId, date);
      
      if (availability == null || !availability['isAvailable']) {
        return [];
      }

      List<Map<String, dynamic>> timeSlots = 
          List<Map<String, dynamic>>.from(availability['timeSlots'] ?? []);

      // Filter out booked slots
      List<Map<String, dynamic>> availableSlots = [];
      
      for (Map<String, dynamic> slot in timeSlots) {
        if (slot['isAvailable'] == true) {
          availableSlots.add(slot);
        }
      }

      return availableSlots;
    } catch (e) {
      print('Error getting available time slots: $e');
      return [];
    }
  }

  // Book a time slot
  Future<bool> bookTimeSlot({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    required String appointmentId,
  }) async {
    try {
      String dateString = _formatDate(date);
      String availabilityId = '${doctorId}_$dateString';

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot availabilityDoc = await transaction.get(
          _firestore.collection('availability').doc(availabilityId)
        );

        if (!availabilityDoc.exists) {
          throw Exception('Availability not found');
        }

        Map<String, dynamic> availabilityData = availabilityDoc.data() as Map<String, dynamic>;
        List<dynamic> timeSlots = availabilityData['timeSlots'] ?? [];

        // Find and update the specific time slot
        bool slotFound = false;
        for (int i = 0; i < timeSlots.length; i++) {
          if (timeSlots[i]['time'] == timeSlot) {
            if (timeSlots[i]['isAvailable'] != true) {
              throw Exception('Time slot is not available');
            }
            timeSlots[i]['isAvailable'] = false;
            timeSlots[i]['appointmentId'] = appointmentId;
            slotFound = true;
            break;
          }
        }

        if (!slotFound) {
          throw Exception('Time slot not found');
        }

        transaction.update(
          _firestore.collection('availability').doc(availabilityId),
          {
            'timeSlots': timeSlots,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        );

        return true;
      });
    } catch (e) {
      print('Error booking time slot: $e');
      return false;
    }
  }

  // Cancel a time slot booking
  Future<bool> cancelTimeSlot({
    required String doctorId,
    required DateTime date,
    required String timeSlot,
    required String appointmentId,
  }) async {
    try {
      String dateString = _formatDate(date);
      String availabilityId = '${doctorId}_$dateString';

      return await _firestore.runTransaction((transaction) async {
        DocumentSnapshot availabilityDoc = await transaction.get(
          _firestore.collection('availability').doc(availabilityId)
        );

        if (!availabilityDoc.exists) {
          throw Exception('Availability not found');
        }

        Map<String, dynamic> availabilityData = availabilityDoc.data() as Map<String, dynamic>;
        List<dynamic> timeSlots = availabilityData['timeSlots'] ?? [];

        // Find and update the specific time slot
        bool slotFound = false;
        for (int i = 0; i < timeSlots.length; i++) {
          if (timeSlots[i]['time'] == timeSlot && 
              timeSlots[i]['appointmentId'] == appointmentId) {
            timeSlots[i]['isAvailable'] = true;
            timeSlots[i].remove('appointmentId');
            slotFound = true;
            break;
          }
        }

        if (!slotFound) {
          throw Exception('Time slot booking not found');
        }

        transaction.update(
          _firestore.collection('availability').doc(availabilityId),
          {
            'timeSlots': timeSlots,
            'updatedAt': FieldValue.serverTimestamp(),
          }
        );

        return true;
      });
    } catch (e) {
      print('Error canceling time slot: $e');
      return false;
    }
  }

  // Generate default time slots for a doctor
  List<Map<String, dynamic>> generateDefaultTimeSlots({
    String startTime = '09:00',
    String endTime = '17:00',
    int slotDuration = 30, // minutes
    List<String> breakTimes = const ['12:00-13:00'], // lunch break
  }) {
    List<Map<String, dynamic>> slots = [];
    
    DateTime start = _parseTimeString(startTime);
    DateTime end = _parseTimeString(endTime);
    
    while (start.isBefore(end)) {
      String timeString = _formatTime(start);
      
      // Check if this time is during a break
      bool isBreakTime = false;
      for (String breakTime in breakTimes) {
        List<String> breakParts = breakTime.split('-');
        if (breakParts.length == 2) {
          DateTime breakStart = _parseTimeString(breakParts[0]);
          DateTime breakEnd = _parseTimeString(breakParts[1]);
          if (!start.isBefore(breakStart) && start.isBefore(breakEnd)) {
            isBreakTime = true;
            break;
          }
        }
      }
      
      if (!isBreakTime) {
        slots.add({
          'time': timeString,
          'isAvailable': true,
          'duration': slotDuration,
        });
      }
      
      start = start.add(Duration(minutes: slotDuration));
    }
    
    return slots;
  }

  // Set doctor's weekly schedule
  Future<bool> setDoctorWeeklySchedule({
    required String doctorId,
    required Map<String, Map<String, dynamic>> weeklySchedule,
  }) async {
    try {
      await _firestore
          .collection('doctorSchedules')
          .doc(doctorId)
          .set({
        'doctorId': doctorId,
        'weeklySchedule': weeklySchedule,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error setting weekly schedule: $e');
      return false;
    }
  }

  // Get doctor's weekly schedule
  Future<Map<String, Map<String, dynamic>>> getDoctorWeeklySchedule(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('doctorSchedules')
          .doc(doctorId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Map<String, Map<String, dynamic>>.from(data['weeklySchedule'] ?? {});
      }

      return {};
    } catch (e) {
      print('Error getting weekly schedule: $e');
      return {};
    }
  }

  // Generate availability for multiple dates based on weekly schedule
  Future<bool> generateAvailabilityFromSchedule({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      Map<String, Map<String, dynamic>> weeklySchedule = 
          await getDoctorWeeklySchedule(doctorId);

      if (weeklySchedule.isEmpty) {
        return false;
      }

      DateTime currentDate = startDate;
      List<String> weekdays = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];

      while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
        String weekday = weekdays[currentDate.weekday - 1];
        
        if (weeklySchedule.containsKey(weekday)) {
          Map<String, dynamic> daySchedule = weeklySchedule[weekday]!;
          
          if (daySchedule['isAvailable'] == true) {
            List<Map<String, dynamic>> timeSlots = generateDefaultTimeSlots(
              startTime: daySchedule['startTime'] ?? '09:00',
              endTime: daySchedule['endTime'] ?? '17:00',
              slotDuration: daySchedule['slotDuration'] ?? 30,
              breakTimes: List<String>.from(daySchedule['breakTimes'] ?? ['12:00-13:00']),
            );

            await setDoctorAvailability(
              doctorId: doctorId,
              date: currentDate,
              timeSlots: timeSlots,
              isAvailable: true,
            );
          }
        }

        currentDate = currentDate.add(Duration(days: 1));
      }

      return true;
    } catch (e) {
      print('Error generating availability from schedule: $e');
      return false;
    }
  }

  // Get calendar events for a user
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get appointments for the user
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('scheduledDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      List<Map<String, dynamic>> events = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;
        
        // Check if user is involved in this appointment
        if (appointmentData['doctorId'] == userId || appointmentData['patientId'] == userId) {
          events.add({
            'id': doc.id,
            'type': 'appointment',
            'title': appointmentData['type'] ?? 'Appointment',
            'startTime': appointmentData['scheduledDateTime'],
            'duration': appointmentData['duration'] ?? 30,
            'status': appointmentData['status'],
            'doctorId': appointmentData['doctorId'],
            'patientId': appointmentData['patientId'],
            'notes': appointmentData['notes'],
          });
        }
      }

      return events;
    } catch (e) {
      print('Error getting calendar events: $e');
      return [];
    }
  }

  // Get today's appointments for a doctor
  Future<List<Map<String, dynamic>>> getTodayAppointments(String doctorId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledDateTime', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledDateTime')
          .get();

      List<Map<String, dynamic>> appointments = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> appointmentData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

        // Get patient info
        try {
          DocumentSnapshot patientDoc = await _firestore
              .collection('users')
              .doc(appointmentData['patientId'])
              .get();

          if (patientDoc.exists) {
            Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
            appointmentData['patientName'] = patientData['displayName'];
            appointmentData['patientPhone'] = patientData['phone'];
            appointmentData['patientEmail'] = patientData['email'];
          }
        } catch (e) {
          print('Error getting patient info: $e');
        }

        appointments.add(appointmentData);
      }

      return appointments;
    } catch (e) {
      print('Error getting today\'s appointments: $e');
      return [];
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  DateTime _parseTimeString(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return DateTime(2024, 1, 1, hour, minute);
  }

  // Stream methods for real-time updates
  Stream<Map<String, dynamic>?> getDoctorAvailabilityStream(String doctorId, DateTime date) {
    String dateString = _formatDate(date);
    return _firestore
        .collection('availability')
        .doc('${doctorId}_$dateString')
        .snapshots()
        .map((doc) => doc.exists ? {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            } : null);
  }

  Stream<List<Map<String, dynamic>>> getCalendarEventsStream({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _firestore
        .collection('appointments')
        .where('scheduledDateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('scheduledDateTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> events = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> appointmentData = doc.data() as Map<String, dynamic>;
        
        // Check if user is involved in this appointment
        if (appointmentData['doctorId'] == userId || appointmentData['patientId'] == userId) {
          events.add({
            'id': doc.id,
            'type': 'appointment',
            'title': appointmentData['type'] ?? 'Appointment',
            'startTime': appointmentData['scheduledDateTime'],
            'duration': appointmentData['duration'] ?? 30,
            'status': appointmentData['status'],
            'doctorId': appointmentData['doctorId'],
            'patientId': appointmentData['patientId'],
            'notes': appointmentData['notes'],
          });
        }
      }

      return events;
    });
  }
}
