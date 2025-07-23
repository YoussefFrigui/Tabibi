import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Get current user as User model
  Future<User?> getCurrentUser() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get current user as Doctor model (only if user is a doctor)
  Future<Doctor?> getCurrentDoctor() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'doctor') {
          return Doctor.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current doctor: $e');
      return null;
    }
  }

  // Get current user as Patient model (only if user is a patient)
  Future<Patient?> getCurrentPatient() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'patient') {
          return Patient.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting current patient: $e');
      return null;
    }
  }

  // Get user by ID as User model
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Get doctor by ID as Doctor model
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(doctorId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'doctor') {
          return Doctor.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting doctor by ID: $e');
      return null;
    }
  }

  // Get patient by ID as Patient model
  Future<Patient?> getPatientById(String patientId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(patientId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'patient') {
          return Patient.fromFirestore(doc);
        }
      }
      return null;
    } catch (e) {
      print('Error getting patient by ID: $e');
      return null;
    }
  }

  // Get all doctors
  Future<List<Doctor>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all doctors: $e');
      return [];
    }
  }

  // Get doctors by specialty
  Future<List<Doctor>> getDoctorsBySpecialty(String specialty) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('specialty', isEqualTo: specialty)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting doctors by specialty: $e');
      return [];
    }
  }

  // Get all patients
  Future<List<Patient>> getAllPatients() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => Patient.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all patients: $e');
      return [];
    }
  }

  // Search doctors by name or specialty
  Future<List<Doctor>> searchDoctors(String searchTerm) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - in production, use Algolia or similar
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('isActive', isEqualTo: true)
          .get();

      final searchLower = searchTerm.toLowerCase();
      
      return snapshot.docs
          .map((doc) => Doctor.fromFirestore(doc))
          .where((doctor) => 
              doctor.displayName.toLowerCase().contains(searchLower) ||
              doctor.specialty.toLowerCase().contains(searchLower))
          .toList();
    } catch (e) {
      print('Error searching doctors: $e');
      return [];
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update({
        ...user.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Update doctor profile with email change support
  Future<bool> updateDoctorProfileWithEmail(Doctor doctor, String newEmail) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      // If email is being changed, update Firebase Auth first
      if (newEmail != currentUser.email) {
        // Update email in Firebase Authentication
        await currentUser.updateEmail(newEmail);
        
        // Send email verification
        await currentUser.sendEmailVerification();
        print('✅ Email updated in Firebase Auth and verification sent');
      }

      // Update the doctor object with new email
      final updatedDoctor = doctor.copyWith(email: newEmail);

      // Update Firestore document
      await _firestore.collection('users').doc(doctor.uid).update({
        ...updatedDoctor.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Doctor profile updated in Firestore');
      return true;
    } catch (e) {
      print('❌ Error updating doctor profile with email: $e');
      
      // Provide more specific error messages
      if (e.toString().contains('requires-recent-login')) {
        throw Exception('Please re-authenticate to change your email address');
      } else if (e.toString().contains('email-already-in-use')) {
        throw Exception('This email address is already in use by another account');
      } else if (e.toString().contains('invalid-email')) {
        throw Exception('Please enter a valid email address');
      } else {
        throw Exception('Failed to update profile: ${e.toString()}');
      }
    }
  }

  // Update doctor profile
  Future<bool> updateDoctorProfile(Doctor doctor) async {
    try {
      await _firestore.collection('users').doc(doctor.uid).update({
        ...doctor.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating doctor profile: $e');
      return false;
    }
  }

  // Update patient profile
  Future<bool> updatePatientProfile(Patient patient) async {
    try {
      await _firestore.collection('users').doc(patient.uid).update({
        ...patient.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error updating patient profile: $e');
      return false;
    }
  }

  // Get user stream (real-time updates)
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }

  // Get current user stream
  Stream<User?> getCurrentUserStream() {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      return getUserStream(userId);
    }
    return Stream.value(null);
  }

  // Get doctor stream
  Stream<Doctor?> getDoctorStream(String doctorId) {
    return _firestore
        .collection('users')
        .doc(doctorId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['role'] == 'doctor') {
              return Doctor.fromFirestore(doc);
            }
          }
          return null;
        });
  }

  // Get all doctors stream
  Stream<List<Doctor>> getAllDoctorsStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList());
  }

  // Update user's FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Deactivate user account
  Future<bool> deactivateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error deactivating user: $e');
      return false;
    }
  }

  // Activate user account
  Future<bool> activateUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error activating user: $e');
      return false;
    }
  }
}
