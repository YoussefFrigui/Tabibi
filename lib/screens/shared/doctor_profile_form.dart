import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

import '../../services/auth_service.dart';
import '../doctor/doctor_dashboard.dart';


class DoctorProfileFormPage extends StatefulWidget {
  final String? userId;
  final String? email;
  final String? password;
  final String? fullName;
  const DoctorProfileFormPage({super.key, this.userId, this.email, this.password, this.fullName});

  @override
  State<DoctorProfileFormPage> createState() => _DoctorProfileFormPageState();
}

class _DoctorProfileFormPageState extends State<DoctorProfileFormPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.email != null && widget.email!.isNotEmpty) {
      emailController.text = widget.email!;
    }
    if (widget.fullName != null && widget.fullName!.isNotEmpty) {
      fullNameController.text = widget.fullName!;
    }
  }

  String? selectedSpecialty;
  DateTime? availabilityDateTime;
  String profileImage = 'assets/1.jpg';

  final List<String> specialties = [
    'Cardiology',
    'Dermatology',
    'Dentistry',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'General Medicine',
  ];

  Future<void> _pickAvailability() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: availabilityDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 9, minute: 0),
        builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          availabilityDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatAvailability() {
    if (availabilityDateTime == null) return 'Select Date & Time';
    return availabilityDateTime!.toLocal().toString().substring(0, 16);
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Register doctor and log in
      final email = emailController.text.trim();
      final password = widget.password ?? '';
      final fullName = fullNameController.text.trim();
      final specialty = selectedSpecialty;
      final experience = experienceController.text.trim();
      final clinic = clinicController.text.trim();
      final phone = phoneController.text.trim();

      // TODO: Get password from previous screen or require it here for real registration
      if (password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is required for registration.')),
        );
        return;
      }

      try {
        // Register doctor
        final authService = AuthService();
        final result = await authService.registerWithEmailAndPassword(
          email,
          password,
          fullName,
          'doctor',
        );
        if (result['success'] == true) {
          // Save doctor profile details (extend as needed)
          await authService.updateUserProfile({
            'specialty': specialty,
            'experience': experience,
            'clinic': clinic,
            'phone': phone,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Profile saved successfully')),
          );
          // Navigate to doctor dashboard, logged in as the new doctor
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => DoctorDashboard()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['error'] ?? 'Registration failed.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _changePhoto() {
    // Simuler un "upload" de photo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(' Change Photo clicked')),
    );
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
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
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
                    'Doctor Profile Form',
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
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: AssetImage(profileImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: AppColors.accent),
                            onPressed: _changePhoto,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _inputField(fullNameController, 'Full Name'),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: selectedSpecialty,
                    decoration: _inputDecoration('Specialty'),
                    items: specialties
                        .map((specialty) => DropdownMenuItem(
                              value: specialty,
                              child: Text(specialty),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => selectedSpecialty = val);
                    },
                    validator: (val) => val == null || val.isEmpty
                        ? 'Please select Specialty'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  _inputField(experienceController, 'Years of Experience',
                      type: TextInputType.number),
                  const SizedBox(height: 12),

                  _inputField(clinicController, 'Clinic / Hospital'),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _pickAvailability,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _inputDecoration('Availability Date & Time'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatAvailability(),
                            style: TextStyle(
                              color: availabilityDateTime != null
                                  ? Colors.black87
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.calendar_today,
                              color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _inputField(phoneController, 'Phone Number',
                      type: TextInputType.phone),
                  const SizedBox(height: 12),

                  _inputField(emailController, 'Email',
                      type: TextInputType.emailAddress),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.edit, color: AppColors.primary),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String label, {
    TextInputType type = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      maxLines: maxLines,
      validator: (val) => val!.isEmpty ? 'Please enter $label' : null,
      decoration: _inputDecoration(label),
    );
  }
}
