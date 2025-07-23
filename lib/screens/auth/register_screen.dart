import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedDay;
  String? selectedMonth;
  String? selectedYear;
  String selectedRole = 'Doctor';
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/in.png',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          controller: nameController,
                          hint: 'Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _inputField(
                          controller: firstNameController,
                          hint: 'First Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _inputField(
                    controller: emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),

                  _passwordField(
                    controller: passwordController,
                    hint: 'Password',
                    isHidden: hidePassword,
                    onToggle: () =>
                        setState(() => hidePassword = !hidePassword),
                  ),
                  const SizedBox(height: 12),

                  _passwordField(
                    controller: confirmPasswordController,
                    hint: 'Confirm Password',
                    isHidden: hideConfirmPassword,
                    onToggle: () => setState(
                        () => hideConfirmPassword = !hideConfirmPassword),
                  ),

                  const SizedBox(height: 10),

                  // Role buttons
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.03),
                          blurRadius: 6,
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        _roleButton('Doctor', Icons.medical_services_outlined),
                        const SizedBox(width: 10),
                        _roleButton('Patient', Icons.group_outlined),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Date of birth
                  Row(
                    children: [
                      Expanded(
                        child: _dobDropdown(
                          hint: 'Day',
                          value: selectedDay,
                          items: List.generate(31, (i) => '${i + 1}'),
                          onChanged: (val) => setState(() => selectedDay = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dobDropdown(
                          hint: 'Month',
                          value: selectedMonth,
                          items: List.generate(12, (i) => '${i + 1}'),
                          onChanged: (val) =>
                              setState(() => selectedMonth = val),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _dobDropdown(
                          hint: 'Year',
                          value: selectedYear,
                          items: List.generate(50, (i) => '${1970 + i}'),
                          onChanged: (val) =>
                              setState(() => selectedYear = val),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
        suffixIcon: IconButton(
          icon: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
            color: AppColors.primary,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _roleButton(String role, IconData icon) {
    final isSelected = selectedRole == role;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() => selectedRole = role);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade50,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isSelected ? 3 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(role, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _dobDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      items: items
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
