import 'package:flutter/material.dart';
import 'dart:async';
import '../services/appointment_service.dart';
import '../models/models.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<Appointment> _appointments = [];
  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _completedAppointments = [];
  List<Appointment> _cancelledAppointments = [];
  List<Appointment> _pendingAppointments = [];
  
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _appointmentStream;

  // Getters
  List<Appointment> get appointments => _appointments;
  List<Appointment> get upcomingAppointments => _upcomingAppointments;
  List<Appointment> get completedAppointments => _completedAppointments;
  List<Appointment> get cancelledAppointments => _cancelledAppointments;
  List<Appointment> get pendingAppointments => _pendingAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  void _updateAppointments(List<Appointment> newAppointments) {
    _appointments = newAppointments;
    _filterAppointmentsByStatus();
    notifyListeners();
  }

  void _filterAppointmentsByStatus() {
    _upcomingAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.confirmed)
        .toList();
    _completedAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.completed)
        .toList();
    _cancelledAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.cancelled)
        .toList();
    _pendingAppointments = _appointments
        .where((apt) => apt.status == AppointmentStatus.pending)
        .toList();
  }

  // Public methods
  Future<void> loadCurrentUserAppointments() async {
    try {
      _setLoading(true);
      _clearError();
      
      final appointments = await _appointmentService.getCurrentUserAppointments();
      _updateAppointments(appointments);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDoctorAppointments(String doctorId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final appointments = await _appointmentService.getDoctorAppointments(doctorId);
      _updateAppointments(appointments);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPatientAppointments(String patientId) async {
    try {
      _setLoading(true);
      _clearError();
      
      final appointments = await _appointmentService.getPatientAppointments(patientId);
      _updateAppointments(appointments);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createAppointment({
    required String doctorId,
    required DateTime scheduledDateTime,
    required String reason,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      // Convert DateTime to separate date and time strings
      final appointmentDate = '${scheduledDateTime.year}-${scheduledDateTime.month.toString().padLeft(2, '0')}-${scheduledDateTime.day.toString().padLeft(2, '0')}';
      final appointmentTime = '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}';
      
      final success = await _appointmentService.createAppointment(
        doctorId: doctorId,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        notes: notes ?? reason,
      );
      
      if (success) {
        await loadCurrentUserAppointments(); // Refresh appointments
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus newStatus) async {
    try {
      _setLoading(true);
      _clearError();
      
      final success = await _appointmentService.updateAppointmentStatus(appointmentId, newStatus);
      if (success) {
        await loadCurrentUserAppointments(); // Refresh appointments
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    return await _appointmentService.cancelAppointment(appointmentId);
  }

  Future<bool> confirmAppointment(String appointmentId) async {
    return await _appointmentService.confirmAppointment(appointmentId);
  }

  Future<bool> completeAppointment(String appointmentId) async {
    return await _appointmentService.completeAppointment(appointmentId);
  }

  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      return await _appointmentService.getAppointmentById(appointmentId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<List<Appointment>> getTodayAppointments() async {
    try {
      return await _appointmentService.getTodayAppointments();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  Future<Map<String, int>> getAppointmentStats(String doctorId) async {
    try {
      return await _appointmentService.getAppointmentStats(doctorId);
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  // Stream methods
  void startListeningToAppointments() {
    _appointmentStream?.cancel();
    _appointmentStream = _appointmentService.getCurrentUserAppointmentsStream()
        .listen(
      (appointments) => _updateAppointments(appointments),
      onError: (error) => _setError(error.toString()),
    );
  }

  void startListeningToPendingAppointments() {
    _appointmentStream?.cancel();
    _appointmentStream = _appointmentService.getPendingAppointmentsStream()
        .listen(
      (appointments) {
        _pendingAppointments = appointments;
        notifyListeners();
      },
      onError: (error) => _setError(error.toString()),
    );
  }

  void stopListeningToAppointments() {
    _appointmentStream?.cancel();
    _appointmentStream = null;
  }

  // Utility methods
  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _appointmentStream?.cancel();
    super.dispose();
  }
}
