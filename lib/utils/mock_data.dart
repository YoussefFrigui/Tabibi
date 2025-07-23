import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Initialize all mock data
  static Future<void> initializeMockData() async {
    try {
      await _createMockUsers();
      await _createMockDoctors();
      await _createMockPatients();
      await _createMockAppointments();
      await _createMockMedicalRecords();
      await _createMockReviews();
      print('✅ Mock data initialized successfully');
    } catch (e) {
      print('❌ Error initializing mock data: $e');
    }
  }

  // Create mock users (auth + profile data)
  static Future<void> _createMockUsers() async {
    final mockUsers = [
      {
        'email': 'doctor@test.com',
        'password': 'doctor123',
        'displayName': 'Dr. Sarah Ahmed',
        'role': 'doctor',
        'phoneNumber': '+1234567890',
        'profilePicture': 'assets/1.jpg',
        'specialty': 'Cardiology',
        'licenseNumber': 'MD123456',
        'experience': '8 years',
        'education': 'MD from Harvard Medical School',
        'clinic': 'Heart Care Center',
        'rating': 4.8,
        'reviewCount': 45,
        'isVerified': true,
        'consultationFee': 150.0,
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
      {
        'email': 'dr.johnson@test.com',
        'password': 'doctor123',
        'displayName': 'Dr. Michael Johnson',
        'role': 'doctor',
        'phoneNumber': '+1234567891',
        'profilePicture': 'assets/2.jpg',
        'specialty': 'Dermatology',
        'licenseNumber': 'MD123457',
        'experience': '12 years',
        'education': 'MD from Johns Hopkins',
        'clinic': 'Skin Care Clinic',
        'rating': 4.6,
        'reviewCount': 38,
        'isVerified': true,
        'consultationFee': 120.0,
        'availability': {
          'monday': {'start': '08:00', 'end': '16:00', 'isAvailable': true},
          'tuesday': {'start': '08:00', 'end': '16:00', 'isAvailable': true},
          'wednesday': {'start': '08:00', 'end': '16:00', 'isAvailable': true},
          'thursday': {'start': '08:00', 'end': '16:00', 'isAvailable': true},
          'friday': {'start': '08:00', 'end': '16:00', 'isAvailable': true},
          'saturday': {'start': '09:00', 'end': '12:00', 'isAvailable': true},
          'sunday': {'start': '09:00', 'end': '12:00', 'isAvailable': false},
        },
      },
      {
        'email': 'dr.lee@test.com',
        'password': 'doctor123',
        'displayName': 'Dr. Emily Lee',
        'role': 'doctor',
        'phoneNumber': '+1234567892',
        'profilePicture': 'assets/den.jpg',
        'specialty': 'Dentistry',
        'licenseNumber': 'DDS123458',
        'experience': '6 years',
        'education': 'DDS from University of Pennsylvania',
        'clinic': 'Bright Smile Dental',
        'rating': 4.9,
        'reviewCount': 52,
        'isVerified': true,
        'consultationFee': 100.0,
        'availability': {
          'monday': {'start': '10:00', 'end': '18:00', 'isAvailable': true},
          'tuesday': {'start': '10:00', 'end': '18:00', 'isAvailable': true},
          'wednesday': {'start': '10:00', 'end': '18:00', 'isAvailable': true},
          'thursday': {'start': '10:00', 'end': '18:00', 'isAvailable': true},
          'friday': {'start': '10:00', 'end': '18:00', 'isAvailable': true},
          'saturday': {'start': '10:00', 'end': '14:00', 'isAvailable': true},
          'sunday': {'start': '10:00', 'end': '14:00', 'isAvailable': false},
        },
      },
      {
        'email': 'patient@test.com',
        'password': 'patient123',
        'displayName': 'John Doe',
        'role': 'patient',
        'phoneNumber': '+1234567893',
        'profilePicture': 'assets/1.jpg',
        'dateOfBirth': '1990-05-15',
        'address': '123 Main St, New York, NY 10001',
        'emergencyContact': '+1234567894',
      },
      {
        'email': 'jane.smith@test.com',
        'password': 'patient123',
        'displayName': 'Jane Smith',
        'role': 'patient',
        'phoneNumber': '+1234567895',
        'profilePicture': 'assets/2.jpg',
        'dateOfBirth': '1985-08-22',
        'address': '456 Oak Ave, Los Angeles, CA 90001',
        'emergencyContact': '+1234567896',
      },
      {
        'email': 'bob.wilson@test.com',
        'password': 'patient123',
        'displayName': 'Bob Wilson',
        'role': 'patient',
        'phoneNumber': '+1234567897',
        'profilePicture': 'assets/1.jpg',
        'dateOfBirth': '1992-12-10',
        'address': '789 Pine St, Chicago, IL 60601',
        'emergencyContact': '+1234567898',
      },
      {
        'email': 'admin@test.com',
        'password': 'admin123',
        'displayName': 'Admin User',
        'role': 'admin',
        'phoneNumber': '+1234567899',
        'profilePicture': 'assets/1.jpg',
      },
    ];

    for (var userData in mockUsers) {
      try {
        // Create user in Firebase Authentication
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: userData['email'] as String,
          password: userData['password'] as String,
        );

        // Update display name
        await userCredential.user!.updateDisplayName(userData['displayName'] as String);

        // Create user document in Firestore
        final Map<String, dynamic> firestoreData = {
          'uid': userCredential.user!.uid,
          'email': userData['email'],
          'displayName': userData['displayName'],
          'role': userData['role'],
          'phoneNumber': userData['phoneNumber'],
          'profilePicture': userData['profilePicture'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'fcmToken': null,
        };

        // Add role-specific fields
        if (userData['role'] == 'doctor') {
          firestoreData.addAll({
            'specialty': userData['specialty'],
            'licenseNumber': userData['licenseNumber'],
            'experience': userData['experience'],
            'education': userData['education'],
            'clinic': userData['clinic'],
            'rating': userData['rating'],
            'reviewCount': userData['reviewCount'],
            'isVerified': userData['isVerified'],
            'consultationFee': userData['consultationFee'],
            'availability': userData['availability'],
          });
        } else if (userData['role'] == 'patient') {
          firestoreData.addAll({
            'dateOfBirth': userData['dateOfBirth'],
            'address': userData['address'],
            'emergencyContact': userData['emergencyContact'],
          });
        }

        await _firestore.collection('users').doc(userCredential.user!.uid).set(firestoreData);
        print('✅ Created user: ${userData['email']} (UID: ${userCredential.user!.uid})');
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('⚠️ User already exists: ${userData['email']}');
          
          // Try to sign in with existing credentials to get the UID and update Firestore
          try {
            UserCredential existingUser = await _auth.signInWithEmailAndPassword(
              email: userData['email'] as String,
              password: userData['password'] as String,
            );
            
            // Update the existing user's Firestore document
            final Map<String, dynamic> firestoreData = {
              'uid': existingUser.user!.uid,
              'email': userData['email'],
              'displayName': userData['displayName'],
              'role': userData['role'],
              'phoneNumber': userData['phoneNumber'],
              'profilePicture': userData['profilePicture'],
              'updatedAt': FieldValue.serverTimestamp(),
              'isActive': true,
              'fcmToken': null,
            };

            // Add role-specific fields
            if (userData['role'] == 'doctor') {
              firestoreData.addAll({
                'specialty': userData['specialty'],
                'licenseNumber': userData['licenseNumber'],
                'experience': userData['experience'],
                'education': userData['education'],
                'clinic': userData['clinic'],
                'rating': userData['rating'],
                'reviewCount': userData['reviewCount'],
                'isVerified': userData['isVerified'],
                'consultationFee': userData['consultationFee'],
                'availability': userData['availability'],
              });
            } else if (userData['role'] == 'patient') {
              firestoreData.addAll({
                'dateOfBirth': userData['dateOfBirth'],
                'address': userData['address'],
                'emergencyContact': userData['emergencyContact'],
              });
            }

            await _firestore.collection('users').doc(existingUser.user!.uid).set(firestoreData);
            print('✅ Updated existing user: ${userData['email']} (UID: ${existingUser.user!.uid})');
            
            // Sign out after updating
            await _auth.signOut();
          } catch (signInError) {
            print('❌ Error updating existing user ${userData['email']}: $signInError');
          }
        } else {
          print('❌ Error creating user ${userData['email']}: $e');
        }
      }
    }
  }

  // Create mock appointments
  static Future<void> _createMockAppointments() async {
    // Get users from Firestore to use their actual UIDs
    final doctorSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();
    final patientSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'patient').get();
    
    if (doctorSnapshot.docs.isEmpty || patientSnapshot.docs.isEmpty) {
      print('❌ No doctors or patients found. Create users first.');
      return;
    }

    final doctors = doctorSnapshot.docs;
    final patients = patientSnapshot.docs;

    final appointments = [
      {
        'appointmentId': 'apt_001',
        'patientId': patients[0].id,
        'doctorId': doctors[0].id,
        'patientName': patients[0].data()['displayName'],
        'doctorName': doctors[0].data()['displayName'],
        'doctorSpecialty': doctors[0].data()['specialty'],
        'appointmentDate': '2025-07-23', // Tomorrow
        'appointmentTime': '10:00',
        'duration': 30,
        'status': 'confirmed',
        'consultationFee': doctors[0].data()['consultationFee'],
        'notes': 'Regular checkup for heart condition',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'appointmentId': 'apt_002',
        'patientId': patients.length > 1 ? patients[1].id : patients[0].id,
        'doctorId': doctors.length > 1 ? doctors[1].id : doctors[0].id,
        'patientName': patients.length > 1 ? patients[1].data()['displayName'] : patients[0].data()['displayName'],
        'doctorName': doctors.length > 1 ? doctors[1].data()['displayName'] : doctors[0].data()['displayName'],
        'doctorSpecialty': doctors.length > 1 ? doctors[1].data()['specialty'] : doctors[0].data()['specialty'],
        'appointmentDate': '2025-07-24', // Day after tomorrow
        'appointmentTime': '14:00',
        'duration': 45,
        'status': 'pending',
        'consultationFee': doctors.length > 1 ? doctors[1].data()['consultationFee'] : doctors[0].data()['consultationFee'],
        'notes': 'Skin rash examination',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'appointmentId': 'apt_003',
        'patientId': patients.length > 2 ? patients[2].id : patients[0].id,
        'doctorId': doctors.length > 2 ? doctors[2].id : doctors[0].id,
        'patientName': patients.length > 2 ? patients[2].data()['displayName'] : patients[0].data()['displayName'],
        'doctorName': doctors.length > 2 ? doctors[2].data()['displayName'] : doctors[0].data()['displayName'],
        'doctorSpecialty': doctors.length > 2 ? doctors[2].data()['specialty'] : doctors[0].data()['specialty'],
        'appointmentDate': '2025-07-25', // Three days from now
        'appointmentTime': '11:00',
        'duration': 60,
        'status': 'confirmed',
        'consultationFee': doctors.length > 2 ? doctors[2].data()['consultationFee'] : doctors[0].data()['consultationFee'],
        'notes': 'Dental cleaning and checkup',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'appointmentId': 'apt_004',
        'patientId': patients[0].id,
        'doctorId': doctors.length > 1 ? doctors[1].id : doctors[0].id,
        'patientName': patients[0].data()['displayName'],
        'doctorName': doctors.length > 1 ? doctors[1].data()['displayName'] : doctors[0].data()['displayName'],
        'doctorSpecialty': doctors.length > 1 ? doctors[1].data()['specialty'] : doctors[0].data()['specialty'],
        'appointmentDate': '2025-07-21', // Yesterday (past appointment)
        'appointmentTime': '15:30',
        'duration': 30,
        'status': 'cancelled',
        'consultationFee': doctors.length > 1 ? doctors[1].data()['consultationFee'] : doctors[0].data()['consultationFee'],
        'notes': 'Mole examination - cancelled by patient',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var appointment in appointments) {
      await _firestore.collection('appointments').doc(appointment['appointmentId'] as String).set(appointment);
    }
  }

  // Create mock medical records
  static Future<void> _createMockMedicalRecords() async {
    // Get users from Firestore to use their actual UIDs
    final doctorSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();
    final patientSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'patient').get();
    
    if (doctorSnapshot.docs.isEmpty || patientSnapshot.docs.isEmpty) {
      print('❌ No doctors or patients found. Create users first.');
      return;
    }

    final doctors = doctorSnapshot.docs;
    final patients = patientSnapshot.docs;

    final medicalRecords = [
      {
        'recordId': 'rec_001',
        'patientId': patients[0].id,
        'doctorId': doctors[0].id,
        'patientName': patients[0].data()['displayName'],
        'doctorName': doctors[0].data()['displayName'],
        'appointmentId': 'apt_001',
        'visitDate': '2025-07-18',
        'visitTime': '10:00',
        'diagnosis': 'Mild hypertension',
        'symptoms': 'Headache, dizziness, fatigue',
        'treatment': 'Prescribed ACE inhibitor, lifestyle changes',
        'prescription': [
          {
            'medication': 'Lisinopril',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '30 days'
          },
          {
            'medication': 'Hydrochlorothiazide',
            'dosage': '25mg',
            'frequency': 'Once daily',
            'duration': '30 days'
          }
        ],
        'notes': 'Patient responds well to treatment. Follow-up in 4 weeks.',
        'vitalSigns': {
          'bloodPressure': '140/90',
          'heartRate': '78',
          'temperature': '98.6°F',
          'weight': '75kg',
          'height': '175cm'
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'recordId': 'rec_002',
        'patientId': patients.length > 1 ? patients[1].id : patients[0].id,
        'doctorId': doctors.length > 1 ? doctors[1].id : doctors[0].id,
        'patientName': patients.length > 1 ? patients[1].data()['displayName'] : patients[0].data()['displayName'],
        'doctorName': doctors.length > 1 ? doctors[1].data()['displayName'] : doctors[0].data()['displayName'],
        'appointmentId': 'apt_002',
        'visitDate': '2025-07-19',
        'visitTime': '14:00',
        'diagnosis': 'Allergic dermatitis',
        'symptoms': 'Red rash, itching, swelling',
        'treatment': 'Topical corticosteroid, antihistamine',
        'prescription': [
          {
            'medication': 'Hydrocortisone cream',
            'dosage': '1%',
            'frequency': 'Apply twice daily',
            'duration': '10 days'
          },
          {
            'medication': 'Cetirizine',
            'dosage': '10mg',
            'frequency': 'Once daily',
            'duration': '7 days'
          }
        ],
        'notes': 'Avoid exposure to known allergens. Return if symptoms worsen.',
        'vitalSigns': {
          'bloodPressure': '120/80',
          'heartRate': '72',
          'temperature': '98.4°F',
          'weight': '60kg',
          'height': '162cm'
        },
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var record in medicalRecords) {
      await _firestore.collection('medical_records').doc(record['recordId'] as String).set(record);
    }
  }

  // Create mock reviews
  static Future<void> _createMockReviews() async {
    // Get users from Firestore to use their actual UIDs
    final doctorSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();
    final patientSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'patient').get();
    
    if (doctorSnapshot.docs.isEmpty || patientSnapshot.docs.isEmpty) {
      print('❌ No doctors or patients found. Create users first.');
      return;
    }

    final doctors = doctorSnapshot.docs;
    final patients = patientSnapshot.docs;

    final reviews = [
      {
        'reviewId': 'review_001',
        'patientId': patients[0].id,
        'doctorId': doctors[0].id,
        'patientName': patients[0].data()['displayName'],
        'doctorName': doctors[0].data()['displayName'],
        'rating': 5,
        'comment': 'Excellent doctor! Very professional and caring. Highly recommend.',
        'appointmentId': 'apt_001',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'reviewId': 'review_002',
        'patientId': patients.length > 1 ? patients[1].id : patients[0].id,
        'doctorId': doctors.length > 1 ? doctors[1].id : doctors[0].id,
        'patientName': patients.length > 1 ? patients[1].data()['displayName'] : patients[0].data()['displayName'],
        'doctorName': doctors.length > 1 ? doctors[1].data()['displayName'] : doctors[0].data()['displayName'],
        'rating': 4,
        'comment': 'Good doctor, explained everything clearly. Wait time was a bit long.',
        'appointmentId': 'apt_002',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'reviewId': 'review_003',
        'patientId': patients.length > 2 ? patients[2].id : patients[0].id,
        'doctorId': doctors.length > 2 ? doctors[2].id : doctors[0].id,
        'patientName': patients.length > 2 ? patients[2].data()['displayName'] : patients[0].data()['displayName'],
        'doctorName': doctors.length > 2 ? doctors[2].data()['displayName'] : doctors[0].data()['displayName'],
        'rating': 5,
        'comment': 'Amazing dentist! Painless procedure and great results.',
        'appointmentId': 'apt_003',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var review in reviews) {
      await _firestore.collection('reviews').doc(review['reviewId'] as String).set(review);
    }
  }

  // Create additional mock data helpers
  static Future<void> _createMockDoctors() async {
    // Get doctors from Firestore to use their actual UIDs
    final doctorSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();
    
    if (doctorSnapshot.docs.isEmpty) {
      print('❌ No doctors found. Create users first.');
      return;
    }

    final doctors = doctorSnapshot.docs;

    // This could include additional doctor-specific data like schedules, specialties, etc.
    final doctorSchedules = [
      {
        'doctorId': doctors[0].id,
        'date': '2025-07-18',
        'slots': [
          {'time': '09:00', 'isAvailable': true, 'isBooked': false},
          {'time': '10:00', 'isAvailable': true, 'isBooked': true},
          {'time': '11:00', 'isAvailable': true, 'isBooked': false},
          {'time': '14:00', 'isAvailable': true, 'isBooked': false},
          {'time': '15:00', 'isAvailable': true, 'isBooked': false},
        ],
      },
      {
        'doctorId': doctors.length > 1 ? doctors[1].id : doctors[0].id,
        'date': '2025-07-19',
        'slots': [
          {'time': '08:00', 'isAvailable': true, 'isBooked': false},
          {'time': '09:00', 'isAvailable': true, 'isBooked': false},
          {'time': '14:00', 'isAvailable': true, 'isBooked': true},
          {'time': '15:00', 'isAvailable': true, 'isBooked': false},
        ],
      },
    ];

    for (var schedule in doctorSchedules) {
      await _firestore.collection('doctor_schedules').doc('${schedule['doctorId']}_${schedule['date']}').set(schedule);
    }
  }

  static Future<void> _createMockPatients() async {
    // Get users from Firestore to use their actual UIDs
    final doctorSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'doctor').get();
    final patientSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'patient').get();
    
    if (doctorSnapshot.docs.isEmpty || patientSnapshot.docs.isEmpty) {
      print('❌ No doctors or patients found. Create users first.');
      return;
    }

    final doctors = doctorSnapshot.docs;
    final patients = patientSnapshot.docs;

    // Additional patient data like medical history, favorites, etc.
    final patientFavorites = [
      {
        'patientId': patients[0].id,
        'favoriteDoctors': [
          doctors[0].id,
          doctors.length > 2 ? doctors[2].id : doctors[0].id
        ],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'patientId': patients.length > 1 ? patients[1].id : patients[0].id,
        'favoriteDoctors': [
          doctors.length > 1 ? doctors[1].id : doctors[0].id
        ],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (var favorite in patientFavorites) {
      await _firestore.collection('patient_favorites').doc(favorite['patientId'] as String).set(favorite);
    }
  }

  // Clear Firebase Authentication users (requires re-authentication)
  static Future<void> clearAuthUsers() async {
    try {
      // Get current user (if any) and sign out
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _auth.signOut();
        print('✅ Signed out current user');
      }
      
      // Note: To delete Firebase Auth users, each user needs to be signed in first
      // This is a limitation of Firebase Auth - you can't delete users from client side without re-authentication
      // In production, you'd use Firebase Admin SDK on the server side
      
      print('⚠️ Firebase Auth users cannot be deleted from client side');
      print('💡 Suggestion: Use Firebase Admin SDK on server, or users will be overwritten on next mock data creation');
    } catch (e) {
      print('❌ Error clearing auth users: $e');
    }
  }

  // Helper method to get all test user emails for reference
  static List<String> getTestUserEmails() {
    return [
      'doctor@test.com',
      'dr.johnson@test.com',
      'dr.lee@test.com',
      'patient@test.com',
      'jane.smith@test.com',
      'bob.wilson@test.com',
      'admin@test.com',
    ];
  }

  // Helper method to validate existing auth users
  static Future<void> validateAuthUsers() async {
    try {
      final emails = getTestUserEmails();
      print('📧 Test user emails that should exist in Firebase Auth:');
      for (String email in emails) {
        print('  - $email');
      }
      
      // Note: Cannot check auth users from client side directly
      // This is just for reference
      print('💡 Use Firebase Console to verify these users exist in Authentication');
    } catch (e) {
      print('❌ Error validating auth users: $e');
    }
  }

  // Complete cleanup - clears both Firestore and attempts Auth cleanup
  static Future<void> completeCleanup() async {
    print('🧹 Starting complete cleanup...');
    await clearMockData();
    await clearAuthUsers();
    print('✅ Complete cleanup finished');
  }

  // Clear all mock data (for testing purposes)
  static Future<void> clearMockData() async {
    try {
      // First, get all users from Firestore to know which Auth users to delete
      final usersSnapshot = await _firestore.collection('users').get();
      
      // Delete users from Firebase Authentication
      for (var userDoc in usersSnapshot.docs) {
        try {
          final userData = userDoc.data();
          final email = userData['email'] as String;
          
          // Note: Due to Firebase Auth limitations, we can't directly delete users by UID from admin SDK
          // In a real app, you'd need Firebase Admin SDK or ask users to re-authenticate
          // For now, we'll just print which users should be deleted
          print('⚠️ Firebase Auth user should be manually deleted: $email');
        } catch (e) {
          print('❌ Error processing user for Auth deletion: $e');
        }
      }
      
      // Clear all Firestore collections
      final collections = ['users', 'appointments', 'medical_records', 'reviews', 'doctor_schedules', 'patient_favorites'];
      
      for (String collection in collections) {
        final snapshot = await _firestore.collection(collection).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        print('✅ Cleared collection: $collection');
      }
      
      print('✅ Mock data cleared from Firestore');
      print('⚠️ Note: Firebase Auth users need to be manually deleted or will be overwritten on next creation');
    } catch (e) {
      print('❌ Error clearing mock data: $e');
    }
  }
}
