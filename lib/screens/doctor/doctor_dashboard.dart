import 'package:flutter/material.dart';
import 'confirm_appointments.dart';
import 'doctor_profile_update.dart';
import 'manage_calendar.dart';
import '../auth/login_screen.dart';
import '../../constants/app_colors.dart';
import '../../services/user_service.dart';
import '../../services/appointment_service.dart';
import '../../models/models.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final UserService _userService = UserService();
  final AppointmentService _appointmentService = AppointmentService();
  
  Doctor? currentDoctor;
  List<Appointment> todayAppointments = [];
  List<Appointment> upcomingAppointments = [];
  Map<String, int> appointmentStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load current doctor
      currentDoctor = await _userService.getCurrentDoctor();
      
      if (currentDoctor != null) {
        // Load today's appointments
        todayAppointments = await _appointmentService.getTodayAppointments();
        
        // Load upcoming appointments (next 7 days)
        final allAppointments = await _appointmentService.getCurrentUserAppointments();
        final now = DateTime.now();
        final sevenDaysFromNow = now.add(const Duration(days: 7));
        
        upcomingAppointments = allAppointments.where((appointment) {
          try {
            final appointmentDateTime = DateTime.parse(appointment.appointmentDate);
            return appointmentDateTime.isAfter(now) && 
                   appointmentDateTime.isBefore(sevenDaysFromNow);
          } catch (e) {
            return false;
          }
        }).toList();
        
        // Sort by date and time
        upcomingAppointments.sort((a, b) {
          final dateCompare = a.appointmentDate.compareTo(b.appointmentDate);
          if (dateCompare != 0) return dateCompare;
          return a.appointmentTime.compareTo(b.appointmentTime);
        });
        
        // Load appointment statistics
        appointmentStats = await _appointmentService.getAppointmentStats(currentDoctor!.uid);
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper method to get today's stats
  Map<String, int> _getTodayStats() {
    int confirmedToday = todayAppointments.where((apt) => apt.status == AppointmentStatus.confirmed).length;
    int cancelledToday = todayAppointments.where((apt) => apt.status == AppointmentStatus.cancelled).length;
    
    return {
      'today': todayAppointments.length,
      'confirmed': confirmedToday,
      'cancelled': cancelledToday,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final todayStats = _getTodayStats();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      endDrawer: _buildDrawer(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
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
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: currentDoctor?.profilePicture != null
                        ? AssetImage(currentDoctor!.profilePicture)
                        : const AssetImage('assets/1.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome, ${currentDoctor?.displayName ?? 'Doctor'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentDoctor?.specialty ?? 'Medical Professional',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 26),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ DASHBOARD STATS
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _dashboardTile(
                    'Today', 
                    '${todayStats['today']} Patients',
                    Icons.people_alt_outlined, 
                    AppColors.accent
                  ),
                  const SizedBox(width: 12),
                  _dashboardTile(
                    'Confirmed', 
                    '${todayStats['confirmed']} Appts',
                    Icons.check_circle_outline, 
                    Colors.green
                  ),
                  const SizedBox(width: 12),
                  _dashboardTile(
                    'Canceled', 
                    '${todayStats['cancelled']} Appts', 
                    Icons.cancel_outlined,
                    Colors.redAccent
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ✅ UPCOMING APPOINTMENTS
              Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              
              // Show upcoming appointments or empty state
              if (upcomingAppointments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No upcoming appointments',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...upcomingAppointments.take(3).map((appointment) {
                  return _appointmentCard(
                    appointment.patientName,
                    '${appointment.appointmentDate} - ${appointment.appointmentTime}',
                    'assets/1.jpg', // Default patient image
                  );
                }),

              const SizedBox(height: 24),

              // ✅ NOTIFICATIONS
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              
              // Show notifications based on pending appointments
              if (upcomingAppointments.where((apt) => apt.status == AppointmentStatus.pending).isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No new notifications',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...upcomingAppointments
                    .where((apt) => apt.status == AppointmentStatus.pending)
                    .take(3)
                    .map((appointment) {
                  return _notificationTile(
                    'New appointment request from ${appointment.patientName}'
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardTile(
      String label, String value, IconData icon, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _appointmentCard(String name, String date, String image) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(image, height: 50, width: 50, fit: BoxFit.cover),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        subtitle: Text(
          date,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }

  Widget _notificationTile(String message) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading:
            Icon(Icons.notifications_active_outlined, color: AppColors.primary),
        title: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 220,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundImage: AssetImage('assets/1.jpg'),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Doctor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.home_outlined, 'Home', context,
                    const DoctorDashboard()),
                _drawerItem(Icons.person_outline, 'Profile', context,
                    const UpdateDoctorProfilePage()),
                _drawerItem(Icons.calendar_today_outlined, 'My Calendar',
                    context, const DoctorManageCalendarScreen()),
                _drawerItem(Icons.check_circle_outline, 'Confirm Appointments',
                    context, const ConfirmAppointmentsScreen()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.logout, size: 22),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                elevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      IconData icon, String label, BuildContext context, Widget destination) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      dense: true,
      horizontalTitleGap: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
