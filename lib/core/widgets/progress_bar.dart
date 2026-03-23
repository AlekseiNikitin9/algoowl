import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Animated progress bar with optional notch marks.
class OwlProgressBar extends StatelessWidget {
  final double progress; // 0.0–1.0
  final double height;
  final bool showNotches;

  const OwlProgressBar({
    super.key,
    required this.progress,
    this.height = 16,
    this.showNotches = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Stack(
          children: [
            // Track
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            // Fill
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuart,
                  width: constraints.maxWidth * progress.clamp(0, 1),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF3DA0FF)],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                );
              },
            ),
            // Notch marks
            if (showNotches)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [0.25, 0.5, 0.75].map((pos) {
                      return Container(
                        width: 1,
                        margin: EdgeInsets.only(
                          left: constraints.maxWidth * pos - 0.5,
                        ),
                        color: Colors.white.withValues(alpha: 0.3),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
