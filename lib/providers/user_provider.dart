import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../services/user_service.dart';
import '../models/models.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  
  User? _currentUser;
  Doctor? _currentDoctor;
  Patient? _currentPatient;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  Doctor? get currentDoctor => _currentDoctor;
  Patient? get currentPatient => _currentPatient;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Role-based getters
  String? get userRole => _currentUser?.role;
  bool get isDoctor => userRole == 'doctor';
  bool get isPatient => userRole == 'patient';
  bool get isAdmin => userRole == 'admin';

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _clearUserData() {
    _currentUser = null;
    _currentDoctor = null;
    _currentPatient = null;
    notifyListeners();
  }

  // Public methods
  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      _clearError();
      
      final user = await _userService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        
        // Load role-specific data
        if (user.role == 'doctor') {
          _currentDoctor = await _userService.getDoctorById(user.uid);
        } else if (user.role == 'patient') {
          _currentPatient = await _userService.getPatientById(user.uid);
        }
      } else {
        _clearUserData();
      }
    } catch (e) {
      _setError(e.toString());
      _clearUserData();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _userService.updateUserProfile(updatedUser);
      if (success) {
        await loadCurrentUser();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDoctorProfile(Doctor updatedDoctor) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _userService.updateDoctorProfile(updatedDoctor);
      if (success) {
        await loadCurrentUser();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDoctorProfileWithEmail(Doctor updatedDoctor, String newEmail) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _userService.updateDoctorProfileWithEmail(updatedDoctor, newEmail);
      if (success) {
        await loadCurrentUser();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePatientProfile(Patient updatedPatient) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _userService.updatePatientProfile(updatedPatient);
      if (success) {
        await loadCurrentUser();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Authentication methods
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _auth.signOut();
      _clearUserData();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Utility methods
  void clearError() {
    _clearError();
  }
}
