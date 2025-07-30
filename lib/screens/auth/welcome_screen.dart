import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/in1.png', height: 250),
            Text(
              'Welcome',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Thanks for joining!\nAccess or create your account below and get started on your journey!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Login button
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'LOGIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Create Account button
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.accent, width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Debug: Database initializer button
            // TextButton(
            //   onPressed: () => Navigator.pushNamed(context, AppRoutes.databaseInitializer),
            //   child: const Text(
            //     'Initialize Database (Debug)',
            //     style: TextStyle(color: Colors.grey, fontSize: 12),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
