import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/auth_header_component.dart';
import 'package:physical_activity_log_app/components/auth_input_component.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeaderComponent(
              height: screenHeight * 0.14,
              showGreeting: false,
            ),
            Expanded(
              child: _SignUpFormCard(
                onBackToLogin: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpFormCard extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const _SignUpFormCard({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onBackToLogin,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: AppColors.primaryTeal,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Back to login',
                    style: TextStyle(
                      color: AppColors.primaryTeal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sign Up',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            const AuthInputComponent(
              icon: Icons.person_outline,
              hintText: 'Full Name',
            ),
            const SizedBox(height: 16),
            const AuthInputComponent(
              icon: Icons.email_outlined,
              hintText: 'Email',
            ),
            const SizedBox(height: 16),
            const AuthInputComponent(
              icon: Icons.lock_outline,
              hintText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            const AuthInputComponent(
              icon: Icons.lock_outline,
              hintText: 'Confirm Password',
              obscureText: true,
            ),
            const SizedBox(height: 28),
            ButtonComponent(
              label: 'Sign Up',
              fullWidth: true,
              fullyRoundedSides: true,
              size: ButtonComponentSize.large,
              color: AppColors.primaryTeal,
              elevation: 0,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
