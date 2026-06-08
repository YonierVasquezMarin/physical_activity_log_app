import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/screens/account_screen.dart';
import 'package:physical_activity_log_app/screens/categories_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CategoriesScreen(),
      ),
    );
  }

  void _openAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AccountScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.screenBackground,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ajustes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Gestionar categorías',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.bodyTextGrey,
                  ),
                  onTap: () => _openCategories(context),
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Cuenta',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.bodyTextGrey,
                  ),
                  onTap: () => _openAccount(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
