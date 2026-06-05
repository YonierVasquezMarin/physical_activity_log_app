import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/auth_header_component.dart';
import 'package:physical_activity_log_app/components/auth_input_component.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/constants/input_limits.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/screens/home_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';
import 'package:physical_activity_log_app/utils/validators.dart';

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

class _SignUpFormCard extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const _SignUpFormCard({required this.onBackToLogin});

  @override
  State<_SignUpFormCard> createState() => _SignUpFormCardState();
}

class _SignUpFormCardState extends State<_SignUpFormCard> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final nameError = Validators.name(_nameController.text);
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmPasswordError = Validators.confirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.registerAndLogin(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: 'Registro exitoso',
        type: AppBottomMessageType.success,
      );

      await Future<void>.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;

      AppBottomMessage.show(
        context,
        message: context.read<AuthProvider>().resolveErrorMessage(error),
        type: AppBottomMessageType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
              onTap: _isLoading ? null : widget.onBackToLogin,
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
            AuthInputComponent(
              icon: Icons.person_outline,
              hintText: 'Full Name',
              controller: _nameController,
              maxLength: InputLimits.nameMax,
              errorText: _nameError,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                }
              },
            ),
            const SizedBox(height: 16),
            AuthInputComponent(
              icon: Icons.email_outlined,
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              maxLength: InputLimits.emailMax,
              errorText: _emailError,
              onChanged: (_) {
                if (_emailError != null) {
                  setState(() => _emailError = null);
                }
              },
            ),
            const SizedBox(height: 16),
            AuthInputComponent(
              icon: Icons.lock_outline,
              hintText: 'Password',
              isPassword: true,
              controller: _passwordController,
              maxLength: InputLimits.passwordMax,
              errorText: _passwordError,
              onChanged: (_) {
                if (_passwordError != null) {
                  setState(() => _passwordError = null);
                }
              },
            ),
            const SizedBox(height: 16),
            AuthInputComponent(
              icon: Icons.lock_outline,
              hintText: 'Confirm Password',
              isPassword: true,
              controller: _confirmPasswordController,
              maxLength: InputLimits.passwordMax,
              errorText: _confirmPasswordError,
              onChanged: (_) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
            ),
            const SizedBox(height: 28),
            AbsorbPointer(
              absorbing: _isLoading,
              child: Opacity(
                opacity: _isLoading ? 0.7 : 1,
                child: ButtonComponent(
                  label: _isLoading ? 'Registrando...' : 'Sign Up',
                  fullWidth: true,
                  fullyRoundedSides: true,
                  size: ButtonComponentSize.large,
                  color: AppColors.primaryTeal,
                  elevation: 0,
                  onPressed: _handleSignUp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
