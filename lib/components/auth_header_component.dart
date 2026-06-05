import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class AuthHeaderComponent extends StatelessWidget {
  final double height;
  final bool showGreeting;

  const AuthHeaderComponent({
    super.key,
    required this.height,
    this.showGreeting = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.primaryTeal,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.mintGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (showGreeting)
            Positioned(
              left: 28,
              top: height * 0.38,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hola!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí podrás registrar tu actividad física',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          if (showGreeting)
            Positioned(
              right: 24,
              bottom: -10,
              child: _PlantIllustration(),
            ),
        ],
      ),
    );
  }
}

class _PlantIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 28,
            left: 18,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 14,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 18,
            child: Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 14,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.mintGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Container(
            width: 52,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
