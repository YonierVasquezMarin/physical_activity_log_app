import 'package:flutter/material.dart';
import 'package:physical_activity_log_app/theme/app_colors.dart';

class EmptyStateComponent extends StatelessWidget {
  const EmptyStateComponent({
    super.key,
    required this.message,
    required this.description,
  });

  final String message;
  final String description;

  static const _imagePath = 'assets/graphics/add_data.png';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              _imagePath,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.bodyTextGrey,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: AppColors.bodyTextGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
