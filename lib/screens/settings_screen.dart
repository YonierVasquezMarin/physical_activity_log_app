import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.screenBackground,
      child: SafeArea(
        child: SizedBox.expand(),
      ),
    );
  }
}
