import 'package:cloud_firestore/cloud_firestore.dart';

class Doctor {
  final String uid;
  final String email;
  final String displayName;
  final String phoneNumber;
  final String profilePicture;
  final String specialty;
  final String licenseNumber;
  final String experience;
  final String education;
  final String clinic;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final double consultationFee;
  final Map<String, dynamic> availability;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Doctor({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.phoneNumber,
    required this.profilePicture,
    required this.specialty,
    required this.licenseNumber,
    required this.experience,
    required this.education,
    required this.clinic,
    required this.rating,
    required this.reviewCount,
    required this.isVerified,
    required this.consultationFee,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  // Create Doctor from Firestore document
  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      specialty: data['specialty'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      experience: data['experience'] ?? '',
      education: data['education'] ?? '',
      clinic: data['clinic'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      availability: data['availability'] ?? {},
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Create Doctor from Map
  factory Doctor.fromMap(Map<String, dynamic> data) {
    return Doctor(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      specialty: data['specialty'] ?? '',
      licenseNumber: data['licenseNumber'] ?? '',
      experience: data['experience'] ?? '',
      education: data['education'] ?? '',
      clinic: data['clinic'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      availability: data['availability'] ?? {},
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
      'role': 'doctor',
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'education': education,
      'clinic': clinic,
      'rating': rating,
      'reviewCount': reviewCount,
      'isVerified': isVerified,
      'consultationFee': consultationFee,
      'availability': availability,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  // Copy with method for updates
  Doctor copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? profilePicture,
    String? specialty,
    String? licenseNumber,
    String? experience,
    String? education,
    String? clinic,
    double? rating,
    int? reviewCount,
    bool? isVerified,
    double? consultationFee,
    Map<String, dynamic>? availability,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Doctor(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      clinic: clinic ?? this.clinic,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isVerified: isVerified ?? this.isVerified,
      consultationFee: consultationFee ?? this.consultationFee,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Doctor(uid: $uid, displayName: $displayName, specialty: $specialty, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Doctor && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
