import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tabibi_1/constants/app_colors.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';

class UpdatePatientProfilePage extends StatefulWidget {
  const UpdatePatientProfilePage({super.key});

  @override
  State<UpdatePatientProfilePage> createState() =>
      _UpdatePatientProfilePageState();
}

class _UpdatePatientProfilePageState extends State<UpdatePatientProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingProfile = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientProfile();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _loadPatientProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    setState(() => _isLoadingProfile = true);
    
    try {
      await userProvider.loadCurrentUser();
      
      final patient = userProvider.currentPatient;
      if (patient != null) {
        _populateFields(patient);
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

  void _populateFields(Patient patient) {
    _fullNameController.text = patient.displayName;
    _emailController.text = patient.email;
    _phoneController.text = patient.phoneNumber;
    _addressController.text = patient.address;
    _emergencyContactController.text = patient.emergencyContact;
    _dateOfBirthController.text = patient.dateOfBirth;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentPatient = userProvider.currentPatient;
      
      if (currentPatient == null) {
        throw Exception('No patient profile found');
      }

      // Create updated patient object
      final updatedPatient = currentPatient.copyWith(
        displayName: _fullNameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        emergencyContact: _emergencyContactController.text,
        dateOfBirth: _dateOfBirthController.text,
      );

      final success = await userProvider.updatePatientProfile(updatedPatient);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(userProvider.error ?? 'Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error updating profile: $e'),
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
                    'Update Patient Profile',
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
                          child: const Icon(Icons.person, size: 48, color: AppColors.primary),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt,
                                color: AppColors.accent),
                            onPressed: () {
                              // TODO: Photo picker
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _inputField(_fullNameController, 'Full Name'),
                  const SizedBox(height: 12),
                  _inputField(_emailController, 'Email',
                      type: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _inputField(_phoneController, 'Phone Number',
                      type: TextInputType.phone),
                  const SizedBox(height: 12),
                  _inputField(_addressController, 'Address'),
                  const SizedBox(height: 12),
                  _inputField(_emergencyContactController, 'Emergency Contact',
                      type: TextInputType.phone),
                  const SizedBox(height: 12),
                  _inputField(_dateOfBirthController, 'Date of Birth'),
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
                      label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
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
