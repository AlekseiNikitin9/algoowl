import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Animated progress bar with red→yellow→green gradient based on progress.
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

  /// Interpolates red→yellow→green based on progress (0→0.5→1).
  static Color _progressColor(double t) {
    final clamped = t.clamp(0.0, 1.0);
    if (clamped <= 0.5) {
      return Color.lerp(
        const Color(0xFFF14A59),
        const Color(0xFFF5A623),
        clamped / 0.5,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFF5A623),
        const Color(0xFF2EC37A),
        (clamped - 0.5) / 0.5,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _progressColor(progress);
    final endColor = Color.lerp(color, Colors.white, 0.25)!;

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
                    gradient: LinearGradient(
                      colors: [color, endColor],
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
