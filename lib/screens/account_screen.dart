import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physical_activity_log_app/components/button_component.dart';
import 'package:physical_activity_log_app/components/confirm_dialog_component.dart';
import 'package:physical_activity_log_app/providers/auth_provider.dart';
import 'package:physical_activity_log_app/screens/login_screen.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static const _destructiveColor = Colors.redAccent;

  void _confirmLogout(BuildContext context) {
    ConfirmDialogComponent.show(
      context,
      message: '¿Deseas cerrar sesión?',
      confirmLabel: 'Cerrar sesión',
      onConfirm: () => _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.screenBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cuenta',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Al cerrar sesión se eliminará tu acceso en este dispositivo y '
                'volverás a la pantalla de inicio de sesión. Para usar la app '
                'de nuevo deberás ingresar tu correo y contraseña.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.bodyTextGrey,
                ),
              ),
              const SizedBox(height: 24),
              ButtonComponent(
                label: 'Cerrar sesión',
                iconData: Icons.logout,
                color: _destructiveColor,
                fullWidth: true,
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
