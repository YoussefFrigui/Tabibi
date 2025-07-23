import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus { pending, confirmed, cancelled, completed }

class Appointment {
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String doctorSpecialty;
  final String appointmentDate;
  final String appointmentTime;
  final int duration;
  final AppointmentStatus status;
  final double consultationFee;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.duration,
    required this.status,
    required this.consultationFee,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create Appointment from Firestore document
  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Appointment(
      appointmentId: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      duration: data['duration'] ?? 30,
      status: _parseStatus(data['status']),
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create Appointment from Map
  factory Appointment.fromMap(Map<String, dynamic> data) {
    return Appointment(
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      appointmentDate: data['appointmentDate'] ?? '',
      appointmentTime: data['appointmentTime'] ?? '',
      duration: data['duration'] ?? 30,
      status: _parseStatus(data['status']),
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Parse status string to enum
  static AppointmentStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      case 'completed':
        return AppointmentStatus.completed;
      default:
        return AppointmentStatus.pending;
    }
  }

  // Convert status enum to string
  String get statusString {
    switch (status) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.completed:
        return 'completed';
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'duration': duration,
      'status': statusString,
      'consultationFee': consultationFee,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  Appointment copyWith({
    String? appointmentId,
    String? patientId,
    String? doctorId,
    String? patientName,
    String? doctorName,
    String? doctorSpecialty,
    String? appointmentDate,
    String? appointmentTime,
    int? duration,
    AppointmentStatus? status,
    double? consultationFee,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      consultationFee: consultationFee ?? this.consultationFee,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Appointment(id: $appointmentId, patient: $patientName, doctor: $doctorName, date: $appointmentDate, time: $appointmentTime, status: $statusString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Appointment && other.appointmentId == appointmentId;
  }

  @override
  int get hashCode => appointmentId.hashCode;
}
