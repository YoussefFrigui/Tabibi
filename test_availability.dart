// Quick test script for doctor availability system
import 'package:flutter/material.dart';
import 'lib/services/doctor_availability_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final service = DoctorAvailabilityService();
  final doctorId = "test_doctor_123";
  final date = "2025-07-23";
  
  print("🧪 Testing Doctor Availability Service");
  print("====================================");
  
  // Test 1: Save availability
  print("\n1️⃣ Testing save availability...");
  final testAvailability = {
    '09:00 AM': true,
    '10:00 AM': false,  // This slot is unavailable
    '11:00 AM': true,
    '12:00 PM': true,
    '02:00 PM': false,  // This slot is unavailable
    '03:00 PM': true,
    '04:00 PM': true,
    '05:00 PM': true,
  };
  
  final saveResult = await service.saveAvailability(
    doctorId: doctorId,
    date: date,
    timeSlots: testAvailability,
  );
  print("Save result: $saveResult");
  
  // Test 2: Get availability
  print("\n2️⃣ Testing get availability...");
  final retrievedAvailability = await service.getAvailability(
    doctorId: doctorId,
    date: date,
  );
  print("Retrieved availability: $retrievedAvailability");
  
  // Test 3: Check specific time slots
  print("\n3️⃣ Testing specific time slot checks...");
  final slot1Available = await service.isTimeSlotAvailable(
    doctorId: doctorId,
    date: date,
    timeSlot: "09:00", // Should be available
  );
  print("09:00 available: $slot1Available");
  
  final slot2Available = await service.isTimeSlotAvailable(
    doctorId: doctorId,
    date: date,
    timeSlot: "10:00", // Should be unavailable
  );
  print("10:00 available: $slot2Available");
  
  // Test 4: Get available time slots
  print("\n4️⃣ Testing get available time slots...");
  final availableSlots = await service.getAvailableTimeSlots(
    doctorId: doctorId,
    date: date,
  );
  print("Available slots: $availableSlots");
  
  // Test 5: Toggle availability
  print("\n5️⃣ Testing toggle time slot availability...");
  final toggleResult = await service.toggleTimeSlotAvailability(
    doctorId: doctorId,
    date: date,
    timeSlot: "11:00 AM", // Toggle this slot
  );
  print("Toggle result: $toggleResult");
  
  // Check the toggled slot
  final afterToggle = await service.getAvailability(
    doctorId: doctorId,
    date: date,
  );
  print("After toggle availability: $afterToggle");
  
  print("\n✅ Test completed!");
}
