import 'package:flutter/material.dart';
import '../utils/mock_data.dart';

class DatabaseInitializerScreen extends StatefulWidget {
  const DatabaseInitializerScreen({super.key});

  @override
  State<DatabaseInitializerScreen> createState() => _DatabaseInitializerScreenState();
}

class _DatabaseInitializerScreenState extends State<DatabaseInitializerScreen> {
  bool isInitializing = false;
  bool isClearing = false;
  bool isCompleteClearing = false;
  String statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Initializer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Database Mock Data Manager',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This will create mock data for testing:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 3 Doctors (Cardiology, Dermatology, Dentistry)'),
                    const Text('• 3 Patients'),
                    const Text('• 1 Admin user'),
                    const Text('• 4 Sample appointments'),
                    const Text('• 2 Medical records'),
                    const Text('• 3 Sample reviews'),
                    const Text('• Doctor schedules and availability'),
                    const Text('• Patient favorites'),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Creates users in both Firebase Auth and Firestore',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: isInitializing ? null : _initializeMockData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isInitializing 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Initializing...'),
                      ],
                    )
                  : const Text('Initialize Mock Data'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: isClearing ? null : _clearMockData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isClearing 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Clearing Firestore...'),
                      ],
                    )
                  : const Text('Clear Firestore Data Only'),
            ),
            
            const SizedBox(height: 10),
            
            ElevatedButton(
              onPressed: isCompleteClearing ? null : _completeCleanup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isCompleteClearing 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text('Complete Cleanup...'),
                      ],
                    )
                  : const Text('Complete Cleanup (Firestore + Auth)'),
            ),
            
            const SizedBox(height: 20),
            
            if (statusMessage.isNotEmpty)
              Card(
                color: statusMessage.contains('Error') ? Colors.red.shade100 : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    statusMessage,
                    style: TextStyle(
                      color: statusMessage.contains('Error') ? Colors.red.shade800 : Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Login Credentials:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Doctor: doctor@test.com / doctor123'),
                    Text('Patient: patient@test.com / patient123'),
                    Text('Admin: admin@test.com / admin123'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Firebase Auth Limitations:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Firebase Auth users cannot be deleted from client side. They will persist and be reused when recreating mock data. For production, use Firebase Admin SDK on server.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeMockData() async {
    setState(() {
      isInitializing = true;
      statusMessage = '';
    });

    try {
      await MockDataService.initializeMockData();
      setState(() {
        statusMessage = '✅ Mock data initialized successfully!\n\nYou can now test the app with the provided login credentials.';
      });
    } catch (e) {
      setState(() {
        statusMessage = '❌ Error initializing mock data: $e';
      });
    } finally {
      setState(() {
        isInitializing = false;
      });
    }
  }

  Future<void> _clearMockData() async {
    setState(() {
      isClearing = true;
      statusMessage = '';
    });

    try {
      await MockDataService.clearMockData();
      setState(() {
        statusMessage = '✅ Firestore data cleared successfully!\n\n⚠️ Note: Firebase Auth users still exist and will be reused on next initialization.';
      });
    } catch (e) {
      setState(() {
        statusMessage = '❌ Error clearing mock data: $e';
      });
    } finally {
      setState(() {
        isClearing = false;
      });
    }
  }

  Future<void> _completeCleanup() async {
    setState(() {
      isCompleteClearing = true;
      statusMessage = '';
    });

    try {
      await MockDataService.completeCleanup();
      setState(() {
        statusMessage = '✅ Complete cleanup finished!\n\n⚠️ Note: Firebase Auth users cannot be deleted from client side. They will be reused on next initialization.';
      });
    } catch (e) {
      setState(() {
        statusMessage = '❌ Error during complete cleanup: $e';
      });
    } finally {
      setState(() {
        isCompleteClearing = false;
      });
    }
  }
}
