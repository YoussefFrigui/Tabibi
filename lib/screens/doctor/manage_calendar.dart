import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../services/doctor_availability_service.dart';

class DoctorManageCalendarScreen extends StatefulWidget {
  const DoctorManageCalendarScreen({super.key});

  @override
  State<DoctorManageCalendarScreen> createState() =>
      _DoctorManageCalendarScreenState();
}

class _DoctorManageCalendarScreenState extends State<DoctorManageCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Appointment> _dayAppointments = [];
  final DoctorAvailabilityService _availabilityService = DoctorAvailabilityService();

  // Default time slots for availability
  final List<String> _timeSlots = [
    '09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM'
  ];

  final Map<String, bool> _availability = {};

  @override
  void initState() {
    super.initState();
    _initializeAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureUserAndLoadData();
    });
  }

  Future<void> _ensureUserAndLoadData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      print('🔍 Current user status:');
      print('  - UserProvider.currentUser: ${userProvider.currentUser?.uid ?? "NULL"}');
      print('  - UserProvider.isLoading: ${userProvider.isLoading}');
      print('  - UserProvider.error: ${userProvider.error ?? "None"}');
      
      // If no user is loaded, try to load it first
      if (userProvider.currentUser == null && !userProvider.isLoading) {
        print('🔄 No user found, loading current user...');
        await userProvider.loadCurrentUser();
        
        if (userProvider.currentUser != null) {
          print('✅ User loaded: ${userProvider.currentUser!.uid} (${userProvider.currentUser!.role})');
        } else {
          print('❌ Still no user after loading attempt');
          if (userProvider.error != null) {
            throw Exception('User loading failed: ${userProvider.error}');
          } else {
            throw Exception('Unable to load user data. Please try logging out and logging back in.');
          }
        }
      }
      
      // Now load the calendar data
      await _loadDayData();
    } catch (e) {
      print('❌ Error in initialization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error loading calendar: $e'),
                const SizedBox(height: 8),
                const Text('Try refreshing or logging out and back in.', 
                    style: TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _ensureUserAndLoadData(),
            ),
          ),
        );
      }
    }
  }

  void _initializeAvailability() {
    for (String slot in _timeSlots) {
      _availability[slot] = true;
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadDayData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      
      print('🔍 Loading calendar data...');
      print('  - Current user: ${user != null ? user.uid : "NULL"}');
      print('  - User role: ${user?.role ?? "Unknown"}');
      
      if (user == null) {
        // Try to load user data if not available
        print('⚠️ User is null, attempting to reload user data...');
        await userProvider.loadCurrentUser();
        final reloadedUser = userProvider.currentUser;
        
        if (reloadedUser == null) {
          throw Exception('No user session found. Please log in again.');
        }
        
        print('✅ User reloaded: ${reloadedUser.uid}');
      }
      
      final currentUser = userProvider.currentUser!;
      print('📱 Using user ID: ${currentUser.uid}');
      print('👨‍⚕️ User role: ${currentUser.role}');

      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.loadCurrentUserAppointments();
      
      // Filter appointments for selected date
      final dateKey = _dateKey(_selectedDate);
      _dayAppointments = appointmentProvider.appointments
          .where((apt) => apt.appointmentDate == dateKey)
          .toList();

      print('📅 Found ${_dayAppointments.length} appointments for $dateKey');

      // Load availability from Firebase
      final savedAvailability = await _availabilityService.getAvailability(
        doctorId: currentUser.uid,
        date: dateKey,
      );
      
      print('⚡ Loaded availability: $savedAvailability');
      
      setState(() {
        _availability.clear();
        _availability.addAll(savedAvailability);
      });

      // Update availability based on existing appointments
      _updateAvailabilityBasedOnAppointments();
      
    } catch (e) {
      print('Error loading calendar data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading calendar data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateAvailabilityBasedOnAppointments() {
    // Don't reset availability - preserve doctor's settings from Firebase
    // Only mark slots as unavailable if there are appointments, but don't override doctor's manual settings
    
    for (Appointment appointment in _dayAppointments) {
      String timeSlot = _convertTo12HourFormat(appointment.appointmentTime);
      if (_availability.containsKey(timeSlot)) {
        // If there's an appointment, this slot is definitely unavailable
        _availability[timeSlot] = false;
      }
    }
  }

  String _convertTo12HourFormat(String time24) {
    // Convert 24-hour format to 12-hour format
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time24; // Return original if conversion fails
    }
  }

  void _toggleAvailability(String timeSlot) async {
    // Check if this slot has an appointment
    bool hasAppointment = _dayAppointments.any((apt) => 
        _convertTo12HourFormat(apt.appointmentTime) == timeSlot);
    
    if (hasAppointment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Cannot modify slot with existing appointment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get current user
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show what's about to happen
    final currentStatus = _availability[timeSlot] ?? false;
    final newStatus = !currentStatus;
    
    setState(() {
      _availability[timeSlot] = newStatus;
    });

    // Save to Firebase immediately
    try {
      final success = await _availabilityService.saveAvailability(
        doctorId: user.uid,
        date: _dateKey(_selectedDate),
        timeSlots: _availability,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus 
                ? '✅ $timeSlot is now AVAILABLE for booking' 
                : '🚫 $timeSlot is now UNAVAILABLE for booking'),
            backgroundColor: newStatus ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Revert the change if save failed
      setState(() {
        _availability[timeSlot] = currentStatus;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser;
      
      if (user == null) {
        throw Exception('User not found');
      }

      final success = await _availabilityService.saveAvailability(
        doctorId: user.uid,
        date: _dateKey(_selectedDate),
        timeSlots: _availability,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Availability updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to save availability');
      }
    } catch (e) {
      print('Error saving availability: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('📅 Manage Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.darkAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _ensureUserAndLoadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 20),
                  _buildAppointmentsList(),
                  const SizedBox(height: 20),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 30),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _ensureUserAndLoadData();
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 20),
                  label: const Text('Change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Scheduled Appointments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_dayAppointments.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_dayAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'No appointments scheduled for this date',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...(_dayAppointments.map((appointment) => _buildAppointmentCard(appointment)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor = Colors.orange;
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        statusColor = Colors.green;
        break;
      case AppointmentStatus.completed:
        statusColor = Colors.blue;
        break;
      case AppointmentStatus.cancelled:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.patientName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${_convertTo12HourFormat(appointment.appointmentTime)} (${appointment.duration} min)',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              appointment.status.name.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Availability Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Toggle time slots to set your availability. Red = Booked, Green = Available, Gray = Unavailable',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = _timeSlots[index];
                final isAvailable = _availability[timeSlot] ?? false;
                final hasAppointment = _dayAppointments.any((apt) => 
                    _convertTo12HourFormat(apt.appointmentTime) == timeSlot);

                return InkWell(
                  onTap: hasAppointment ? null : () => _toggleAvailability(timeSlot),
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasAppointment 
                          ? Colors.red[100]
                          : isAvailable 
                              ? Colors.green[100] 
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hasAppointment 
                            ? Colors.red
                            : isAvailable 
                                ? Colors.green 
                                : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasAppointment 
                              ? Icons.event_busy
                              : isAvailable 
                                  ? Icons.check_circle 
                                  : Icons.block,
                          color: hasAppointment 
                              ? Colors.red
                              : isAvailable 
                                  ? Colors.green 
                                  : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeSlot,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: hasAppointment 
                                ? Colors.red[700]
                                : isAvailable 
                                    ? Colors.green[700] 
                                    : Colors.grey[700],
                          ),
                        ),
                        Text(
                          hasAppointment 
                              ? 'BOOKED'
                              : isAvailable 
                                  ? 'OPEN'
                                  : 'BLOCKED',
                          style: TextStyle(
                            fontSize: 10,
                            color: hasAppointment 
                                ? Colors.red[700]
                                : isAvailable 
                                    ? Colors.green[700] 
                                    : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveAvailability,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Saving...', style: TextStyle(fontSize: 16)),
                ],
              )
            : const Text('💾 Save Availability', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
