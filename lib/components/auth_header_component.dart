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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryDeep,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -30,
            left: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.highlight.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            top: height * 0.12,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.steelGrey.withValues(alpha: 0.2),
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
                    '¡A entrenar!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra tus entrenamientos y progreso',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
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
              child: const _DumbbellIllustration(),
            ),
        ],
      ),
    );
  }
}

class _DumbbellIllustration extends StatelessWidget {
  const _DumbbellIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 72,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.steelGrey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Positioned(
            left: 0,
            child: _WeightPlate(size: 44),
          ),
          Positioned(
            right: 0,
            child: _WeightPlate(size: 44),
          ),
          Positioned(
            left: 14,
            child: _WeightPlate(size: 28, inner: true),
          ),
          Positioned(
            right: 14,
            child: _WeightPlate(size: 28, inner: true),
          ),
        ],
      ),
    );
  }
}

class _WeightPlate extends StatelessWidget {
  final double size;
  final bool inner;

  const _WeightPlate({
    required this.size,
    this.inner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.35,
      height: size,
      decoration: BoxDecoration(
        color: inner ? AppColors.plateGrey : AppColors.steelGrey,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: inner ? AppColors.plateGrey : AppColors.highlight.withValues(alpha: 0.55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
