import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/screens/home_screen.dart';
import 'package:physical_activity_log_app/screens/login_screen.dart';

class InitScreen extends StatelessWidget {
  const InitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return context.watch<AuthProvider>().isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();
  }
}
