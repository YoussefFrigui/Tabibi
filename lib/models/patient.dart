import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String profilePicture;
  final String dateOfBirth;
  final String address;
  final String emergencyContact;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Patient({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.dateOfBirth,
    required this.address,
    required this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  // Create Patient from Firestore document
  factory Patient.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Patient(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Create Patient from Map
  factory Patient.fromMap(Map<String, dynamic> data) {
    return Patient(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': 'patient',
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'dateOfBirth': dateOfBirth,
      'address': address,
      'emergencyContact': emergencyContact,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  // Copy with method for updates
  Patient copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? profilePicture,
    String? dateOfBirth,
    String? address,
    String? emergencyContact,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Patient(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Patient(uid: $uid, displayName: $displayName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Patient && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
