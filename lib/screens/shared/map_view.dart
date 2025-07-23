import 'package:flutter/material.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ خريطة الأطباء')),
      body: const Center(
        child: Text(
          'Google Maps widget here',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
