import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/screens/login_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Actividad Física',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryTeal,
          primary: AppColors.primaryTeal,
        ),
        scaffoldBackgroundColor: AppColors.screenBackground,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
