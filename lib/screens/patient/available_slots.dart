import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/appointment_service.dart';
import '../../services/doctor_availability_service.dart';

class CheckAppointmentPage extends StatefulWidget {
  final Doctor doctor;
  
  const CheckAppointmentPage({super.key, required this.doctor});

  @override
  State<CheckAppointmentPage> createState() => _CheckAppointmentPageState();
}

class _CheckAppointmentPageState extends State<CheckAppointmentPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedTime;
  final AppointmentService _appointmentService = AppointmentService();
  final DoctorAvailabilityService _availabilityService = DoctorAvailabilityService();
  final TextEditingController _notesController = TextEditingController();
  bool _isBooking = false;
  bool _loadingSlots = false;
  List<String> _availableTimeSlots = [];

  // Common time slots 
  final List<String> _commonTimeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableSlots();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableSlots() async {
    setState(() {
      _loadingSlots = true;
    });

    try {
      final dateString = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      
      final availableSlots = await _availabilityService.getAvailableTimeSlots(
        doctorId: widget.doctor.uid,
        date: dateString,
      );

      setState(() {
        _availableTimeSlots = availableSlots;
        _loadingSlots = false;
      });
    } catch (e) {
      print('Error loading available slots: $e');
      setState(() {
        _availableTimeSlots = _commonTimeSlots; // Fallback to common slots
        _loadingSlots = false;
      });
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    // Parse time string like "09:00 AM" to TimeOfDay
    final parts = timeStr.split(' ');
    final timePart = parts[0];
    final period = parts[1];
    
    final timeComponents = timePart.split(':');
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    
    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _bookAppointment() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time for your appointment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Format date and time
      final dateString = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      final timeString = "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      print('🔍 Checking availability and booking appointment with:');
      print('  - Doctor ID: ${widget.doctor.uid}');
      print('  - Date: $dateString');
      print('  - Time: $timeString');

      // Check if the time slot is available
      final isAvailable = await _availabilityService.isTimeSlotAvailable(
        doctorId: widget.doctor.uid,
        date: dateString,
        timeSlot: timeString,
      );

      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ This time slot is not available. Please choose another time.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('✅ Time slot is available, proceeding with booking...');

      final success = await _appointmentService.createAppointment(
        doctorId: widget.doctor.uid,
        appointmentDate: dateString,
        appointmentTime: timeString,
        notes: _notesController.text.trim(),
        duration: 30,
      );

      print('📝 Appointment creation result: $success');

      if (success) {
        if (mounted) {
          // Update the appointment provider
          final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
          await appointmentProvider.loadCurrentUserAppointments();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Appointment booked with ${widget.doctor.displayName} on $dateString at $timeString',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate back to home screen
          Navigator.of(context).pop(); // Just go back one screen instead of clearing everything
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to book appointment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.95),
                AppColors.primary.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Appointement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Doctor Profile Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: widget.doctor.profilePicture.isNotEmpty
                        ? NetworkImage(widget.doctor.profilePicture)
                        : null,
                    child: widget.doctor.profilePicture.isEmpty
                        ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.doctor.specialty,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkAccent,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Calendar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book your Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CalendarDatePicker(
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    onDateChanged: (date) {
                      setState(() {
                        selectedDate = date;
                        selectedTime = null; // Clear selected time when date changes
                      });
                      _loadAvailableSlots(); // Reload available slots for new date
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ TIME SELECTION
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Show loading or available time slots
                  if (_loadingSlots)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_availableTimeSlots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No available time slots for this date. Please choose another date.',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Available time slots grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                      ),
                      itemCount: _availableTimeSlots.length,
                      itemBuilder: (context, index) {
                        final timeSlot = _availableTimeSlots[index];
                        final timeOfDay = _parseTimeString(timeSlot);
                        final isSelected = selectedTime?.hour == timeOfDay.hour &&
                            selectedTime?.minute == timeOfDay.minute;
                        
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedTime = timeOfDay;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : AppColors.primary.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                timeSlot,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Colors.white 
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ NOTES SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Describe your symptoms or reason for visit...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isBooking ? null : _bookAppointment,
                icon: _isBooking 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  _isBooking ? 'Booking...' : 'Confirm Appointment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.accent.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Widget _drawerItem(
  //     IconData icon, String label, BuildContext context, Widget? destination) {
  //   return ListTile(
  //     leading: Icon(icon, color: AppColors.primary, size: 24),
  //     title: Text(
  //       label,
  //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  //     ),
  //     onTap: () {
  //       Navigator.pop(context);
  //       if (destination != null) {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => destination),
  //         );
  //       }
  //     },
  //     dense: true,
  //     horizontalTitleGap: 12,
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  //   );
  // }
}
