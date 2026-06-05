import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/auth_header_component.dart';
import 'package:physical_activity_log_app/components/auth_input_component.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/screens/signup_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AuthHeaderComponent(height: screenHeight * 0.32),
            Expanded(
              child: _LoginFormCard(
                onSignUpPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SignUpScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginFormCard extends StatelessWidget {
  final VoidCallback onSignUpPressed;

  const _LoginFormCard({required this.onSignUpPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                color: AppColors.primaryTeal,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 28),
            ButtonComponent(
              label: 'Login',
              fullWidth: true,
              fullyRoundedSides: true,
              size: ButtonComponentSize.large,
              color: AppColors.primaryTeal,
              elevation: 0,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: AppColors.bodyTextGrey,
                    fontSize: 14,
                  ),
                  children: [
                    const TextSpan(text: "Don't have account? "),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: onSignUpPressed,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
