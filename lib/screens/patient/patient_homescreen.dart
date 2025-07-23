import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/models.dart';
import '../../services/user_service.dart';
import '../../providers/providers.dart';
import '../shared/doctor_profile.dart';
import '../auth/login_screen.dart';
import 'patient_profile_update.dart';
import 'patient_calendar.dart';
import 'favorites.dart';
import 'write_review.dart';

class SearchDoctorsScreen extends StatefulWidget {
  const SearchDoctorsScreen({super.key});

  @override
  State<SearchDoctorsScreen> createState() => _SearchDoctorsScreenState();
}

class _SearchDoctorsScreenState extends State<SearchDoctorsScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  
  bool isLoading = true;
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  
  List<String> specialties = [
    'Cardiology',
    'Dermatology', 
    'Dentistry',
    'Orthopedics',
    'Pediatrics',
    'Neurology',
    'Oncology',
    'Psychiatry'
  ];

  @override
  void initState() {
    super.initState();
    // Defer data loading until after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      // Use Provider.of without listen to avoid build issues
      final userProvider = context.read<UserProvider>();
      await userProvider.loadCurrentUser();
      
      if (mounted) {
        setState(() {
          // Patient data will be loaded via Consumer
        });
      }
      
      final doctors = await _userService.getAllDoctors();
      
      if (mounted) {
        setState(() {
          allDoctors = doctors;
          filteredDoctors = doctors;
        });
      }
      
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDoctors = allDoctors;
      } else {
        filteredDoctors = allDoctors.where((doctor) {
          return doctor.displayName.toLowerCase().contains(query.toLowerCase()) ||
                 doctor.specialty.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterBySpecialty(String specialty) {
    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        return doctor.specialty.toLowerCase() == specialty.toLowerCase();
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      endDrawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ HEADER AVEC TITRE ET MENU
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final user = userProvider.currentUser;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user != null 
                                    ? 'Welcome ${user.displayName}!'
                                    : 'Welcome!',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Find your specialist doctor',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.white, size: 28),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ✅ SEARCH BAR MODERNE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterDoctors,
                    decoration: InputDecoration(
                      hintText: 'Search for doctors, specialties...',
                      prefixIcon: Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ✅ BOUTONS ACTIONS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _filterDoctors(_searchController.text.trim());
                          } else {
                            // Show all doctors
                            setState(() {
                              filteredDoctors = allDoctors;
                            });
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Search'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _openFilterModal(context),
                        icon: const Icon(Icons.filter_alt_outlined),
                        label: Text('Apply Filter',
                            style: TextStyle(color: AppColors.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ✅ CATEGORIES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _categoryCard('Dental', 'assets/den.jpg', 'Dentistry'),
                      const SizedBox(width: 16),
                      _categoryCard('Dermatology', 'assets/derm.jpg', 'Dermatology'),
                      const SizedBox(width: 16),
                      _categoryCard('Cardiology', 'assets/1.jpg', 'Cardiology'),
                      const SizedBox(width: 16),
                      _categoryCard('Pediatrics', 'assets/2.jpg', 'Pediatrics'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ✅ DOCTORS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Available Doctors',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    if (filteredDoctors.length > 3)
                      TextButton(
                        onPressed: () {
                          // Show all doctors - could navigate to a full list screen
                        },
                        child: Text(
                          'View All (${filteredDoctors.length})',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (filteredDoctors.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterDoctors('');
                            },
                            child: const Text('Clear Search'),
                          ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredDoctors.take(3).map((doctor) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: doctor.profilePicture.isNotEmpty
                            ? Image.network(
                                doctor.profilePicture,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 50,
                                    width: 50,
                                    color: AppColors.primary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                      ),
                      title: Text(
                        doctor.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor.specialty),
                          if (doctor.rating > 0)
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' ${doctor.rating.toStringAsFixed(1)}'),
                              ],
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: AppColors.primary),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen(doctor: doctor),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileScreen(doctor: doctor),
                          ),
                        );
                      },
                    ),
                  ),
                )),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(String title, String imagePath, String specialty) {
    return GestureDetector(
      onTap: () => _filterBySpecialty(specialty),
      child: Container(
        width: 140,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.medical_services,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // HEADER
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final patient = userProvider.currentPatient;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: patient?.profilePicture != null && patient!.profilePicture.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(26),
                              child: Image.network(
                                patient.profilePicture,
                                width: 52,
                                height: 52,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.person, color: Colors.white, size: 30);
                                },
                              ),
                            )
                          : Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        patient?.displayName ?? 'Patient',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // MENU
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(Icons.home_outlined, 'Home', context, null),
                _drawerItem(Icons.person_outline, 'Profile', context,
                    const UpdatePatientProfilePage()),
                _drawerItem(Icons.event_available_outlined, 'My Calendar',
                    context, const PatientViewCalendarScreen()),
                _drawerItem(Icons.favorite_border, 'Favorites', context,
                    const FavoritesScreen()),
                _drawerItem(Icons.rate_review_outlined, 'Write Reviews',
                    context, const WriteReviewsScreen()),
                _drawerItem(Icons.refresh, 'Refresh', context, null, onTap: _loadData),
                _drawerItem(Icons.settings_outlined, 'Settings', context, null),
              ],
            ),
          ),

          // LOGOUT
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
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
      IconData icon, String label, BuildContext context, Widget? destination, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        if (onTap != null) {
          onTap();
        } else if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        }
      },
      dense: true,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedSpecialty;
  String? selectedFacilityType;
  double rating = 3;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Text(
              'Filter Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Specialty Dropdown
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration('Medical Specialty'),
              value: selectedSpecialty,
              items: [
                'Cardiology',
                'Dermatology',
                'Dentistry',
                'Orthopedics',
                'Pediatrics'
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => selectedSpecialty = val),
            ),
            const SizedBox(height: 12),

            // Facility Type Dropdown
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration('Type of Facility'),
              value: selectedFacilityType,
              items: ['Public', 'Private']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedFacilityType = val),
            ),
            const SizedBox(height: 16),

            // Patient Ratings
            Text(
              'Minimum Patient Rating: ${rating.toStringAsFixed(1)} ⭐',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 8,
              activeColor: AppColors.accent,
              label: rating.toStringAsFixed(1),
              onChanged: (val) => setState(() => rating = val),
            ),
            const SizedBox(height: 16),

            // Working Hours
            Row(
              children: [
                Expanded(
                  child: _timePickerButton(
                    label: 'Start Time',
                    time: startTime,
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => startTime = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _timePickerButton(
                    label: 'End Time',
                    time: endTime,
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (picked != null) setState(() => endTime = picked);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _timePickerButton({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.schedule_outlined),
      label: Text(
        time != null ? time.format(context) : label,
        style: const TextStyle(fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

void _openFilterModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const FilterBottomSheet(),
  );
}
