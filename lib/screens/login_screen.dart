import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/components/auth_header_component.dart';
import 'package:physical_activity_log_app/components/auth_input_component.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/constants/input_limits.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/screens/home_screen.dart';
import 'package:physical_activity_log_app/screens/signup_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';
import 'package:physical_activity_log_app/utils/validators.dart';

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

class _LoginFormCard extends StatefulWidget {
  final VoidCallback onSignUpPressed;

  const _LoginFormCard({required this.onSignUpPressed});

  @override
  State<_LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<_LoginFormCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

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
            const SizedBox(height: 28),
            AbsorbPointer(
              absorbing: _isLoading,
              child: Opacity(
                opacity: _isLoading ? 0.7 : 1,
                child: ButtonComponent(
                  label: _isLoading ? 'Ingresando...' : 'Login',
                  fullWidth: true,
                  fullyRoundedSides: true,
                  size: ButtonComponentSize.large,
                  color: AppColors.primaryTeal,
                  elevation: 0,
                  onPressed: _handleLogin,
                ),
              ),
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
                        onTap: _isLoading ? null : widget.onSignUpPressed,
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
