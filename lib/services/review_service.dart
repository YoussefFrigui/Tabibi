import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a review
  Future<bool> createReview({
    required String doctorId,
    required String appointmentId,
    required double rating,
    required String comment,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Check if user has already reviewed this doctor
      QuerySnapshot existingReview = await _firestore
          .collection('reviews')
          .where('patientId', isEqualTo: userId)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      if (existingReview.docs.isNotEmpty) {
        print('User has already reviewed this appointment');
        return false;
      }

      // Create the review
      await _firestore.collection('reviews').add({
        'patientId': userId,
        'doctorId': doctorId,
        'appointmentId': appointmentId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update doctor's rating
      await _updateDoctorRating(doctorId);

      return true;
    } catch (e) {
      print('Error creating review: $e');
      return false;
    }
  }

  // Update a review
  Future<bool> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Check if user owns the review
      DocumentSnapshot reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) return false;

      Map<String, dynamic> reviewData = reviewDoc.data() as Map<String, dynamic>;
      if (reviewData['patientId'] != userId) return false;

      // Update the review
      await _firestore.collection('reviews').doc(reviewId).update({
        'rating': rating,
        'comment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update doctor's rating
      await _updateDoctorRating(reviewData['doctorId']);

      return true;
    } catch (e) {
      print('Error updating review: $e');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(String reviewId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Check if user owns the review
      DocumentSnapshot reviewDoc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();

      if (!reviewDoc.exists) return false;

      Map<String, dynamic> reviewData = reviewDoc.data() as Map<String, dynamic>;
      if (reviewData['patientId'] != userId) return false;

      String doctorId = reviewData['doctorId'];

      // Delete the review
      await _firestore.collection('reviews').doc(reviewId).delete();

      // Update doctor's rating
      await _updateDoctorRating(doctorId);

      return true;
    } catch (e) {
      print('Error deleting review: $e');
      return false;
    }
  }

  // Get reviews for a doctor
  Future<List<Map<String, dynamic>>> getDoctorReviews(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> reviews = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> reviewData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

        // Get patient name
        try {
          DocumentSnapshot patientDoc = await _firestore
              .collection('users')
              .doc(reviewData['patientId'])
              .get();

          if (patientDoc.exists) {
            Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
            reviewData['patientName'] = patientData['displayName'] ?? 'Anonymous';
            reviewData['patientAvatar'] = patientData['profilePicture'];
          }
        } catch (e) {
          reviewData['patientName'] = 'Anonymous';
        }

        reviews.add(reviewData);
      }

      return reviews;
    } catch (e) {
      print('Error getting doctor reviews: $e');
      return [];
    }
  }

  // Get reviews by a patient
  Future<List<Map<String, dynamic>>> getPatientReviews(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('patientId', isEqualTo: patientId)
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> reviews = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> reviewData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

        // Get doctor name
        try {
          DocumentSnapshot doctorDoc = await _firestore
              .collection('users')
              .doc(reviewData['doctorId'])
              .get();

          if (doctorDoc.exists) {
            Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
            reviewData['doctorName'] = doctorData['displayName'] ?? 'Unknown Doctor';
            reviewData['doctorSpecialty'] = doctorData['specialty'];
            reviewData['doctorAvatar'] = doctorData['profilePicture'];
          }
        } catch (e) {
          reviewData['doctorName'] = 'Unknown Doctor';
        }

        reviews.add(reviewData);
      }

      return reviews;
    } catch (e) {
      print('Error getting patient reviews: $e');
      return [];
    }
  }

  // Get doctor rating statistics
  Future<Map<String, dynamic>> getDoctorRatingStats(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingBreakdown': {
            '5': 0,
            '4': 0,
            '3': 0,
            '2': 0,
            '1': 0,
          },
        };
      }

      List<double> ratings = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as double)
          .toList();

      double totalRating = ratings.reduce((a, b) => a + b);
      double averageRating = totalRating / ratings.length;

      // Calculate rating breakdown
      Map<String, int> ratingBreakdown = {
        '5': 0,
        '4': 0,
        '3': 0,
        '2': 0,
        '1': 0,
      };

      for (double rating in ratings) {
        String ratingKey = rating.floor().toString();
        ratingBreakdown[ratingKey] = (ratingBreakdown[ratingKey] ?? 0) + 1;
      }

      return {
        'averageRating': averageRating,
        'totalReviews': ratings.length,
        'ratingBreakdown': ratingBreakdown,
      };
    } catch (e) {
      print('Error getting doctor rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingBreakdown': {
          '5': 0,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        },
      };
    }
  }

  // Check if user can review a doctor
  Future<bool> canReviewDoctor(String doctorId, String appointmentId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Check if appointment is completed
      DocumentSnapshot appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!appointmentDoc.exists) return false;

      Map<String, dynamic> appointmentData = appointmentDoc.data() as Map<String, dynamic>;
      
      // User must be the patient and appointment must be completed
      if (appointmentData['patientId'] != userId || 
          appointmentData['status'] != 'completed') {
        return false;
      }

      // Check if user has already reviewed this appointment
      QuerySnapshot existingReview = await _firestore
          .collection('reviews')
          .where('patientId', isEqualTo: userId)
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentId', isEqualTo: appointmentId)
          .get();

      return existingReview.docs.isEmpty;
    } catch (e) {
      print('Error checking if user can review doctor: $e');
      return false;
    }
  }

  // Get review by appointment ID
  Future<Map<String, dynamic>?> getReviewByAppointment(String appointmentId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('patientId', isEqualTo: userId)
          .where('appointmentId', isEqualTo: appointmentId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return {
          'id': snapshot.docs.first.id,
          ...snapshot.docs.first.data() as Map<String, dynamic>,
        };
      }

      return null;
    } catch (e) {
      print('Error getting review by appointment: $e');
      return null;
    }
  }

  // Update doctor's overall rating
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      Map<String, dynamic> stats = await getDoctorRatingStats(doctorId);
      
      await _firestore.collection('users').doc(doctorId).update({
        'rating': stats['averageRating'],
        'totalReviews': stats['totalReviews'],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating doctor rating: $e');
    }
  }

  // Get top rated doctors
  Future<List<Map<String, dynamic>>> getTopRatedDoctors({int limit = 10}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('rating', isGreaterThan: 0)
          .orderBy('rating', descending: true)
          .orderBy('totalReviews', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              })
          .toList();
    } catch (e) {
      print('Error getting top rated doctors: $e');
      return [];
    }
  }

  // Get reviews stream for real-time updates
  Stream<List<Map<String, dynamic>>> getDoctorReviewsStream(String doctorId) {
    return _firestore
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> reviews = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> reviewData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

        // Get patient name
        try {
          DocumentSnapshot patientDoc = await _firestore
              .collection('users')
              .doc(reviewData['patientId'])
              .get();

          if (patientDoc.exists) {
            Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
            reviewData['patientName'] = patientData['displayName'] ?? 'Anonymous';
            reviewData['patientAvatar'] = patientData['profilePicture'];
          }
        } catch (e) {
          reviewData['patientName'] = 'Anonymous';
        }

        reviews.add(reviewData);
      }

      return reviews;
    });
  }

  // Report a review
  Future<bool> reportReview(String reviewId, String reason) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      await _firestore.collection('reports').add({
        'reviewId': reviewId,
        'reportedBy': userId,
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error reporting review: $e');
      return false;
    }
  }

  // Get recent reviews for admin
  Future<List<Map<String, dynamic>>> getRecentReviews({int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      List<Map<String, dynamic>> reviews = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> reviewData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

        // Get patient and doctor names
        try {
          DocumentSnapshot patientDoc = await _firestore
              .collection('users')
              .doc(reviewData['patientId'])
              .get();

          DocumentSnapshot doctorDoc = await _firestore
              .collection('users')
              .doc(reviewData['doctorId'])
              .get();

          if (patientDoc.exists) {
            Map<String, dynamic> patientData = patientDoc.data() as Map<String, dynamic>;
            reviewData['patientName'] = patientData['displayName'] ?? 'Anonymous';
          }

          if (doctorDoc.exists) {
            Map<String, dynamic> doctorData = doctorDoc.data() as Map<String, dynamic>;
            reviewData['doctorName'] = doctorData['displayName'] ?? 'Unknown Doctor';
          }
        } catch (e) {
          reviewData['patientName'] = 'Anonymous';
          reviewData['doctorName'] = 'Unknown Doctor';
        }

        reviews.add(reviewData);
      }

      return reviews;
    } catch (e) {
      print('Error getting recent reviews: $e');
      return [];
    }
  }
}
