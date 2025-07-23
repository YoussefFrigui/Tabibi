import 'package:flutter/material.dart';

class AvailabilityCalendarPage extends StatelessWidget {
  const AvailabilityCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final slots = [
      'الإثنين 9:00 - 10:00',
      'الإثنين 10:00 - 11:00',
      'الثلاثاء 14:00 - 15:00',
      'الخميس 9:00 - 12:00',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('📅 اختر الموعد')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: slots.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(slots[index]),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/confirmation');
                },
                child: const Text('احجز'),
              ),
            ),
          );
        },
      ),
    );
  }
}
