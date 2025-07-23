import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String recordId;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String appointmentId;
  final String visitDate;
  final String visitTime;
  final String diagnosis;
  final String symptoms;
  final String treatment;
  final List<Prescription> prescription;
  final String notes;
  final VitalSigns vitalSigns;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicalRecord({
    required this.recordId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.appointmentId,
    required this.visitDate,
    required this.visitTime,
    required this.diagnosis,
    required this.symptoms,
    required this.treatment,
    required this.prescription,
    required this.notes,
    required this.vitalSigns,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create MedicalRecord from Firestore document
  factory MedicalRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecord(
      recordId: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      visitDate: data['visitDate'] ?? '',
      visitTime: data['visitTime'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      symptoms: data['symptoms'] ?? '',
      treatment: data['treatment'] ?? '',
      prescription: _parsePrescription(data['prescription']),
      notes: data['notes'] ?? '',
      vitalSigns: VitalSigns.fromMap(data['vitalSigns'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create MedicalRecord from Map
  factory MedicalRecord.fromMap(Map<String, dynamic> data) {
    return MedicalRecord(
      recordId: data['recordId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      visitDate: data['visitDate'] ?? '',
      visitTime: data['visitTime'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      symptoms: data['symptoms'] ?? '',
      treatment: data['treatment'] ?? '',
      prescription: _parsePrescription(data['prescription']),
      notes: data['notes'] ?? '',
      vitalSigns: VitalSigns.fromMap(data['vitalSigns'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Parse prescription list
  static List<Prescription> _parsePrescription(dynamic prescriptionData) {
    if (prescriptionData is List) {
      return prescriptionData
          .map((item) => Prescription.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'appointmentId': appointmentId,
      'visitDate': visitDate,
      'visitTime': visitTime,
      'diagnosis': diagnosis,
      'symptoms': symptoms,
      'treatment': treatment,
      'prescription': prescription.map((p) => p.toMap()).toList(),
      'notes': notes,
      'vitalSigns': vitalSigns.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  String toString() {
    return 'MedicalRecord(id: $recordId, patient: $patientName, doctor: $doctorName, diagnosis: $diagnosis)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MedicalRecord && other.recordId == recordId;
  }

  @override
  int get hashCode => recordId.hashCode;
}

class Prescription {
  final String medication;
  final String dosage;
  final String frequency;
  final String duration;

  const Prescription({
    required this.medication,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory Prescription.fromMap(Map<String, dynamic> data) {
    return Prescription(
      medication: data['medication'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medication': medication,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }

  @override
  String toString() {
    return 'Prescription(medication: $medication, dosage: $dosage, frequency: $frequency, duration: $duration)';
  }
}

class VitalSigns {
  final String bloodPressure;
  final String heartRate;
  final String temperature;
  final String weight;
  final String height;

  const VitalSigns({
    required this.bloodPressure,
    required this.heartRate,
    required this.temperature,
    required this.weight,
    required this.height,
  });

  factory VitalSigns.fromMap(Map<String, dynamic> data) {
    return VitalSigns(
      bloodPressure: data['bloodPressure'] ?? '',
      heartRate: data['heartRate'] ?? '',
      temperature: data['temperature'] ?? '',
      weight: data['weight'] ?? '',
      height: data['height'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'temperature': temperature,
      'weight': weight,
      'height': height,
    };
  }

  @override
  String toString() {
    return 'VitalSigns(BP: $bloodPressure, HR: $heartRate, Temp: $temperature, Weight: $weight, Height: $height)';
  }
}
