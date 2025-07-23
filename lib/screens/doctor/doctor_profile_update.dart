import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/app_colors.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class UpdateDoctorProfilePage extends StatefulWidget {
  const UpdateDoctorProfilePage({super.key});

  @override
  State<UpdateDoctorProfilePage> createState() =>
      _UpdateDoctorProfilePageState();
}

class _UpdateDoctorProfilePageState extends State<UpdateDoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  // Form controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _clinicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();

  String _selectedSpecialty = 'General Medicine';
  DateTime? _availabilityDateTime;

  final List<String> _specialties = [
    'General Medicine',
    'Cardiology',
    'Dermatology',
    'Dentistry',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Neurology',
    'Oncology',
    'Endocrinology'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctorProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _experienceController.dispose();
    _clinicController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _licenseNumberController.dispose();
    _educationController.dispose();
    _consultationFeeController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctorProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    setState(() => _isLoadingProfile = true);
    
    try {
      await userProvider.loadCurrentUser();
      
      final doctor = userProvider.currentDoctor;
      if (doctor != null) {
        _populateFields(doctor);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingProfile = false);
    }
  }

  void _populateFields(Doctor doctor) {
    _fullNameController.text = doctor.displayName;
    _experienceController.text = doctor.experience;
    _clinicController.text = doctor.clinic;
    _phoneController.text = doctor.phoneNumber;
    _emailController.text = doctor.email;
    _licenseNumberController.text = doctor.licenseNumber;
    _educationController.text = doctor.education;
    _consultationFeeController.text = doctor.consultationFee.toString();
    
    setState(() {
      _selectedSpecialty = doctor.specialty.isNotEmpty ? doctor.specialty : 'General Medicine';
    });
  }

  Future<void> _pickAvailability() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _availabilityDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 9, minute: 0),
      );

      if (pickedTime != null) {
        setState(() {
          _availabilityDateTime = DateTime(
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
    if (_availabilityDateTime == null) return 'Select Date & Time';
    return _availabilityDateTime!.toLocal().toString().substring(0, 16);
  }

  Future<bool> _showReAuthDialog() async {
    final passwordController = TextEditingController();
    bool isReAuthenticating = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('🔐 Re-authentication Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'To change your email address, please enter your current password:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isReAuthenticating ? null : () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isReAuthenticating ? null : () async {
                final password = passwordController.text.trim();
                if (password.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter your password')),
                  );
                  return;
                }

                setState(() => isReAuthenticating = true);

                try {
                  final user = FirebaseAuth.instance.currentUser!;
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: password,
                  );
                  
                  await user.reauthenticateWithCredential(credential);
                  Navigator.of(context).pop(true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Invalid password: ${e.toString()}')),
                  );
                  setState(() => isReAuthenticating = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: isReAuthenticating 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Verify'),
            ),
          ],
        ),
      ),
    );

    passwordController.dispose();
    return result ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentDoctor = userProvider.currentDoctor;
      
      if (currentDoctor == null) {
        throw Exception('No doctor profile found');
      }

      // Check if email has changed
      final currentEmail = currentDoctor.email;
      final newEmail = _emailController.text.trim();
      final emailChanged = currentEmail != newEmail;

      // Create updated doctor object
      final updatedDoctor = currentDoctor.copyWith(
        displayName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        specialty: _selectedSpecialty,
        licenseNumber: _licenseNumberController.text,
        experience: _experienceController.text,
        education: _educationController.text,
        clinic: _clinicController.text,
        consultationFee: double.tryParse(_consultationFeeController.text) ?? currentDoctor.consultationFee,
      );

      bool success;
      
      if (emailChanged) {
        // Use the special method that handles email changes
        success = await userProvider.updateDoctorProfileWithEmail(updatedDoctor, newEmail);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated! Please check your new email for verification.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        // Use the regular update method
        success = await userProvider.updateDoctorProfile(updatedDoctor);
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (success && mounted) {
        Navigator.pop(context);
      } else {
        throw Exception(userProvider.error ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        // Handle re-authentication requirement
        if (e.toString().contains('requires-recent-login')) {
          final shouldReAuth = await _showReAuthDialog();
          if (shouldReAuth) {
            // Retry the save operation after re-authentication
            return _saveProfile();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error updating profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Update Profile'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

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
                    'Update Doctor Profile',
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
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: AppColors.accent),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image picker coming soon!')),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),

                  _inputField(_fullNameController, 'Full Name'),
                  const SizedBox(height: 12),
                  
                  // Specialty Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialty,
                    decoration: _inputDecoration('Specialty'),
                    items: _specialties
                        .map((specialty) => DropdownMenuItem(
                              value: specialty,
                              child: Text(specialty),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedSpecialty = val ?? _selectedSpecialty),
                  ),
                  const SizedBox(height: 12),
                  
                  _inputField(_experienceController, 'Years of Experience', 
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  
                  _inputField(_licenseNumberController, 'License Number'),
                  const SizedBox(height: 12),
                  
                  _inputField(_educationController, 'Education'),
                  const SizedBox(height: 12),
                  
                  _inputField(_clinicController, 'Affiliated Hospital/Clinic'),
                  const SizedBox(height: 12),
                  
                  _inputField(_consultationFeeController, 'Consultation Fee (\$)', 
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),

                  // Availability Picker
                  InkWell(
                    onTap: _pickAvailability,
                    borderRadius: BorderRadius.circular(16),
                    child: InputDecorator(
                      decoration: _inputDecoration('Next Available'),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatAvailability(),
                            style: TextStyle(
                              color: _availabilityDateTime != null 
                                  ? Colors.black87 
                                  : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.calendar_today, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _inputField(_phoneController, 'Phone Number', 
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputField(_emailController, 'Email', 
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          '💡 Changing email will require verification',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveProfile,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Updating...' : 'Save Changes'),
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

  Widget _inputField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      maxLines: maxLines,
      enabled: enabled,
      decoration: _inputDecoration(label),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        
        // Email validation
        if (keyboardType == TextInputType.emailAddress) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email address';
          }
        }
        
        // Phone number validation
        if (keyboardType == TextInputType.phone) {
          final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
          if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
            return 'Please enter a valid phone number';
          }
        }
        
        return null;
      },
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
}
