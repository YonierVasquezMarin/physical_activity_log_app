import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/components/app_bottom_message.dart';
import 'package:physical_activity_log_app/screens/goals_screen.dart';
import 'package:physical_activity_log_app/screens/reports_screen.dart';
import 'package:physical_activity_log_app/screens/sessions_screen.dart';
import 'package:physical_activity_log_app/screens/settings_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showSuccessMessage = false});

  final bool showSuccessMessage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const _screens = <Widget>[
    SessionsScreen(),
    GoalsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.showSuccessMessage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        AppBottomMessage.show(
          context,
          message: 'Ingreso exitoso',
          type: AppBottomMessageType.success,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.bodyTextGrey,
        backgroundColor: AppColors.screenBackground,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Sesiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            activeIcon: Icon(Icons.flag),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
