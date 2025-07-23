import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String reviewId;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final int rating;
  final String comment;
  final String appointmentId;
  final DateTime createdAt;

  const Review({
    required this.reviewId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.rating,
    required this.comment,
    required this.appointmentId,
    required this.createdAt,
  });

  // Create Review from Firestore document
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      reviewId: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create Review from Map
  factory Review.fromMap(Map<String, dynamic> data) {
    return Review(
      reviewId: data['reviewId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      patientName: data['patientName'] ?? '',
      doctorName: data['doctorName'] ?? '',
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'patientId': patientId,
      'doctorId': doctorId,
      'patientName': patientName,
      'doctorName': doctorName,
      'rating': rating,
      'comment': comment,
      'appointmentId': appointmentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() {
    return 'Review(id: $reviewId, patient: $patientName, doctor: $doctorName, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review && other.reviewId == reviewId;
  }

  @override
  int get hashCode => reviewId.hashCode;
}
