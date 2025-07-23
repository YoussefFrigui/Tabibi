import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user role from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      return {
        'success': true,
        'user': result.user,
        'role': userData['role'],
        'userData': userData,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Login failed: ${e.toString()}',
      };
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String role,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'email': email,
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'profilePicture': null,
        'phoneNumber': null,
        'fcmToken': null,
        
        // Initialize role-specific fields
        if (role == 'doctor') ...{
          'specialty': null,
          'licenseNumber': null,
          'experience': null,
          'education': null,
          'clinic': null,
          'rating': 0.0,
          'reviewCount': 0,
          'isVerified': false,
          'consultationFee': null,
          'availability': {
            'monday': {'start': '09:00', 'end': '17:00', 'isAvailable': true},
            'tuesday': {'start': '09:00', 'end': '17:00', 'isAvailable': true},
            'wednesday': {'start': '09:00', 'end': '17:00', 'isAvailable': true},
            'thursday': {'start': '09:00', 'end': '17:00', 'isAvailable': true},
            'friday': {'start': '09:00', 'end': '17:00', 'isAvailable': true},
            'saturday': {'start': '09:00', 'end': '13:00', 'isAvailable': false},
            'sunday': {'start': '09:00', 'end': '13:00', 'isAvailable': false},
          },
        },
        
        if (role == 'patient') ...{
          'dateOfBirth': null,
          'address': null,
          'emergencyContact': null,
        },
      });

      return {
        'success': true,
        'user': result.user,
        'role': role,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'error': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // Get user role
  Future<String?> getUserRole() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists) {
          return (doc.data() as Map<String, dynamic>)['role'] as String?;
        }
      } catch (e) {
        print('Error getting user role: $e');
      }
    }
    return null;
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }
    return null;
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> userData) async {
    if (currentUser != null) {
      try {
        await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .update({
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return true;
      } catch (e) {
        print('Error updating user profile: $e');
        return false;
      }
    }
    return false;
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user stream
  Stream<Map<String, dynamic>?> getUserStream() {
    if (currentUser != null) {
      return _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots()
          .map((doc) => doc.exists ? doc.data() : null);
    }
    return Stream.value(null);
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'An authentication error occurred.';
    }
  }
}
