import 'package:flutter/material.dart';
import 'package:tabibi_1/constants/app_colors.dart';

import 'package:tabibi_1/models/models.dart';
import 'package:tabibi_1/screens/patient/available_slots.dart';
import 'package:provider/provider.dart';
import 'package:tabibi_1/providers/providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorProfileScreen({required this.doctor, super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}


class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  double _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  Doctor? _doctor;

  Future<void> _submitReview() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final patient = userProvider.currentPatient;
    final reviewText = _reviewController.text.trim();
    if (patient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in as a patient to submit a review.")),
      );
      return;
    }
    if (reviewText.isEmpty || _currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and review text.")),
      );
      return;
    }
    try {
      final reviewData = {
        'doctorId': widget.doctor.uid,
        'patientId': patient.uid,
        'patientName': patient.displayName,
        'rating': _currentRating,
        'review': reviewText,
        'createdAt': FieldValue.serverTimestamp(),
      };
      // Save review to Firestore (collection: reviews)
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);

      // Update doctor's rating and review count
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('doctorId', isEqualTo: widget.doctor.uid)
          .get();
      final reviews = reviewsSnapshot.docs;
      double avgRating = 0;
      if (reviews.isNotEmpty) {
        avgRating = reviews
            .map((doc) => (doc['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
            reviews.length;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctor.uid)
          .update({
        'rating': avgRating,
        'reviewCount': reviews.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload doctor data to update UI
      final docSnap = await FirebaseFirestore.instance.collection('users').doc(widget.doctor.uid).get();
      setState(() {
        _doctor = Doctor.fromFirestore(docSnap);
        _currentRating = 0;
      });
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Review submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting review: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = _doctor ?? widget.doctor;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Column(
        children: [
          // 🔷 Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          final patient = userProvider.currentPatient;
                          final isFavorite = patient?.favoriteDoctors.contains(doctor.uid) ?? false;
                          return IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                            onPressed: patient == null ? null : () async {
                              final updatedFavorites = List<String>.from(patient.favoriteDoctors);
                              if (isFavorite) {
                                updatedFavorites.remove(doctor.uid);
                              } else {
                                updatedFavorites.add(doctor.uid);
                              }
                              await userProvider.updatePatientProfile(
                                patient.copyWith(favoriteDoctors: updatedFavorites),
                              );
                              // Optionally show feedback
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: doctor.profilePicture.isNotEmpty
                        ? NetworkImage(doctor.profilePicture)
                        : const AssetImage('assets/1.jpg') as ImageProvider,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.displayName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < doctor.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amberAccent,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔷 Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoStatsCard(),
                  const SizedBox(height: 24),
                  _aboutSection(),
                  const SizedBox(height: 24),
                  _contactSection(),
                  const SizedBox(height: 28),
                  _bookNowButton(context),
                  const SizedBox(height: 28),
                  _writeReviewSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CheckAppointmentPage(doctor: widget.doctor),
            ),
          );
        },
        icon: const Icon(Icons.calendar_month),
        label: const Text(
          'Check Appointment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _writeReviewSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final patient = userProvider.currentPatient;
        final isPatient = patient != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Write a Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _currentRating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: isPatient ? () => setState(() => _currentRating = index + 1.0) : null,
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              enabled: isPatient,
              decoration: InputDecoration(
                hintText: isPatient ? "Write your feedback..." : "Login as a patient to review",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPatient ? _submitReview : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("Submit Review"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoStatsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _InfoStat(label: 'Reviews', value: widget.doctor.reviewCount.toString()),
            _InfoStat(label: 'Experience', value: widget.doctor.experience.isNotEmpty ? widget.doctor.experience : '--'),
            _InfoStat(label: 'Rating', value: widget.doctor.rating > 0 ? widget.doctor.rating.toStringAsFixed(1) : '--'),
          ],
        ),
      ),
    );
  }

  Widget _aboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          widget.doctor.education.isNotEmpty
              ? widget.doctor.education
              : 'No education/bio available.',
          style: const TextStyle(fontSize: 14, height: 1.5),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _contactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(label: 'Full Name', value: widget.doctor.displayName),
                _InfoRow(label: 'Specialty', value: widget.doctor.specialty),
                _InfoRow(label: 'Experience', value: widget.doctor.experience.isNotEmpty ? widget.doctor.experience : '--'),
                _InfoRow(label: 'Clinic', value: widget.doctor.clinic.isNotEmpty ? widget.doctor.clinic : '--'),
                _InfoRow(label: 'Email', value: widget.doctor.email),
                _InfoRow(label: 'Phone', value: widget.doctor.phoneNumber),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoStat extends StatelessWidget {
  final String label;
  final String value;
  const _InfoStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 6,
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}
