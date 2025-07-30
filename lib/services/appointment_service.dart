import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/models.dart';
import 'doctor_availability_service.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Create new appointment
  Future<bool> createAppointment({
    required String doctorId,
    required String appointmentDate,
    required String appointmentTime,
    required String notes,
    int duration = 30,
  }) async {
    try {
      String? patientId = _auth.currentUser?.uid;
      print('🔍 Current user ID: $patientId');
      
      if (patientId == null) {
        print('❌ No current user found');
        return false;
      }

      // Get patient and doctor details
      DocumentSnapshot patientDoc = await _firestore.collection('users').doc(patientId).get();
      DocumentSnapshot doctorDoc = await _firestore.collection('users').doc(doctorId).get();

      print('📋 Patient doc exists: ${patientDoc.exists}');
      print('📋 Doctor doc exists: ${doctorDoc.exists}');

      if (!patientDoc.exists || !doctorDoc.exists) {
        print('❌ Patient or doctor document not found');
        return false;
      }

      final patientData = patientDoc.data() as Map<String, dynamic>;
      final doctorData = doctorDoc.data() as Map<String, dynamic>;

      print('👤 Patient: ${patientData['displayName']}');
      print('👨‍⚕️ Doctor: ${doctorData['displayName']}');

      // Generate appointment ID
      String appointmentId = _firestore.collection('appointments').doc().id;
      print('🆔 Generated appointment ID: $appointmentId');

      // Create appointment
      Appointment appointment = Appointment(
        appointmentId: appointmentId,
        patientId: patientId,
        doctorId: doctorId,
        patientName: patientData['displayName'] ?? '',
        doctorName: doctorData['displayName'] ?? '',
        doctorSpecialty: doctorData['specialty'] ?? '',
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        duration: duration,
        status: AppointmentStatus.pending,
        consultationFee: (doctorData['consultationFee'] ?? 0.0).toDouble(),
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('💾 Saving appointment to Firestore...');
      await _firestore.collection('appointments').doc(appointmentId).set(appointment.toMap());
      print('✅ Appointment saved successfully');
      return true;
    } catch (e) {
      print('Error creating appointment: $e');
      return false;
    }
  }

  // Get appointments for current user
  Future<List<Appointment>> getCurrentUserAppointments() async {
    try {
      String? userId = _auth.currentUser?.uid;
      print('🔍 Getting appointments for user: $userId');
      
      if (userId == null) {
        print('❌ No current user found');
        return [];
      }

      // Get user role to determine query
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('❌ User document not found');
        return [];
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      String role = userData['role'] ?? '';
      print('👤 User role: $role');

      QuerySnapshot snapshot;
      if (role == 'doctor') {
        print('🔍 Querying appointments where doctorId = $userId');
        snapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: userId)
            .get(); // Removed orderBy temporarily
      } else {
        print('🔍 Querying appointments where patientId = $userId');
        snapshot = await _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .get(); // Removed orderBy temporarily
      }

      print('📋 Found ${snapshot.docs.length} appointments');
      final appointments = snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
      
      // Sort appointments by date on client side
      appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
      
      for (var apt in appointments) {
        print('  - ${apt.appointmentDate} ${apt.appointmentTime}: ${apt.doctorName} (${apt.status.name})');
      }
      
      return appointments;
    } catch (e) {
      print('Error getting user appointments: $e');
      return [];
    }
  }

  // Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(AppointmentStatus status) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Get user role to determine query
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      String role = userData['role'] ?? '';

      QuerySnapshot snapshot;
      if (role == 'doctor') {
        snapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: userId)
            .where('status', isEqualTo: status.name)
            .get(); // Removed orderBy temporarily
      } else {
        snapshot = await _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .where('status', isEqualTo: status.name)
            .get(); // Removed orderBy temporarily
      }

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting appointments by status: $e');
      return [];
    }
  }

  // Get doctor's appointments
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get(); // Removed orderBy temporarily

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting doctor appointments: $e');
      return [];
    }
  }

  // Get patient's appointments
  Future<List<Appointment>> getPatientAppointments(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get(); // Removed orderBy temporarily

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting patient appointments: $e');
      return [];
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error cancelling appointment: $e');
      return false;
    }
  }

  // Confirm appointment (doctor only)
  Future<bool> confirmAppointment(String appointmentId) async {
    try {
      // 1. Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Fetch appointment details
      final doc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (!doc.exists) {
        print('Error: appointment not found after confirming');
        return false;
      }
      final data = doc.data() as Map<String, dynamic>;
      final String doctorId = data['doctorId'];
      final String appointmentDate = data['appointmentDate'];
      final String appointmentTime = data['appointmentTime'];

      // 3. Mark the slot as unavailable
      final DoctorAvailabilityService availabilityService = DoctorAvailabilityService();
      // Get current availability for the date
      final Map<String, bool> slots = await availabilityService.getAvailability(
        doctorId: doctorId,
        date: appointmentDate,
      );
      // Mark the slot as unavailable (false)
      slots[appointmentTime] = false;
      await availabilityService.saveAvailability(
        doctorId: doctorId,
        date: appointmentDate,
        timeSlots: slots,
      );

      return true;
    } catch (e) {
      print('Error confirming appointment: $e');
      return false;
    }
  }

  // Complete appointment (doctor only)
  Future<bool> completeAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.completed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error completing appointment: $e');
      return false;
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (doc.exists) {
        return Appointment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting appointment by ID: $e');
      return null;
    }
  }

  // Get appointments stream for real-time updates
  Stream<List<Appointment>> getCurrentUserAppointmentsStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .get()
        .asStream()
        .asyncExpand((userDoc) {
          if (!userDoc.exists) return Stream.value([]);
          
          final userData = userDoc.data() as Map<String, dynamic>;
          String role = userData['role'] ?? '';

          if (role == 'doctor') {
            return _firestore
                .collection('appointments')
                .where('doctorId', isEqualTo: userId)
                .snapshots() // Removed orderBy temporarily
                .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
          } else {
            return _firestore
                .collection('appointments')
                .where('patientId', isEqualTo: userId)
                .snapshots() // Removed orderBy temporarily
                .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
          }
        });
  }

  // Get pending appointments for doctor
  Stream<List<Appointment>> getPendingAppointmentsStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: userId)
        .where('status', isEqualTo: AppointmentStatus.pending.name)
        .snapshots() // Removed orderBy temporarily
        .map((snapshot) => snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList());
  }

  // Get today's appointments
  Future<List<Appointment>> getTodayAppointments() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      // Get user role to determine query
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final userData = userDoc.data() as Map<String, dynamic>;
      String role = userData['role'] ?? '';

      String today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD format

      QuerySnapshot snapshot;
      if (role == 'doctor') {
        snapshot = await _firestore
            .collection('appointments')
            .where('doctorId', isEqualTo: userId)
            .where('appointmentDate', isEqualTo: today)
            .get(); // Removed orderBy temporarily
      } else {
        snapshot = await _firestore
            .collection('appointments')
            .where('patientId', isEqualTo: userId)
            .where('appointmentDate', isEqualTo: today)
            .get(); // Removed orderBy temporarily
      }

      return snapshot.docs.map((doc) => Appointment.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting today appointments: $e');
      return [];
    }
  }

  // Get appointment statistics for doctor
  Future<Map<String, int>> getAppointmentStats(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      Map<String, int> stats = {
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        String status = data['status'] ?? '';
        
        stats['total'] = stats['total']! + 1;
        if (stats.containsKey(status)) {
          stats[status] = stats[status]! + 1;
        }
      }

      return stats;
    } catch (e) {
      print('Error getting appointment stats: $e');
      return {};
    }
  }
}
