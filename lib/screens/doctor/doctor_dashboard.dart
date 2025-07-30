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
    final List<Map<String, dynamic>> drawerItems = [
      {
        'icon': Icons.home_outlined,
        'label': 'Home',
        'page': const DoctorDashboard(),
      },
      {
        'icon': Icons.person_outline,
        'label': 'Profile',
        'page': const UpdateDoctorProfilePage(),
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'My Calendar',
        'page': const DoctorManageCalendarScreen(),
      },
      {
        'icon': Icons.check_circle_outline,
        'label': 'Confirm Appointments',
        'page': const ConfirmAppointmentsScreen(),
      },
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.9),
              AppColors.primary.withOpacity(0.95)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(48),
            bottomRight: Radius.circular(48),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: Column(
          children: [
            // ✅ En-tête avec avatar
            Row(
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
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // ✅ Liste des items
            Expanded(
              child: ListView.builder(
                itemCount: drawerItems.length,
                itemBuilder: (context, index) {
                  final item = drawerItems[index];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: ListTile(
                      dense: true,
                      horizontalTitleGap: 8,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: Icon(
                        item['icon'],
                        color: Colors.white,
                        size: 22,
                      ),
                      title: Text(
                        item['label'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => item['page']),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // ✅ Bouton Logout stylé
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
