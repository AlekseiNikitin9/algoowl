import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Pill-shaped Light ↔ Dark slider — icon only, no text labels.
class ThemeToggle extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChange;

  const ThemeToggle({super.key, required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackBg = isDark ? AppColors.darkSurface : AppColors.surfaceAlt;
    final trackBorder = isDark ? AppColors.darkBorder : AppColors.border;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: trackBorder),
      ),
      child: Row(
        children: [
          _Segment(
            icon: Icons.light_mode_rounded,
            selected: value == ThemeMode.light,
            onTap: () {
              HapticFeedback.selectionClick();
              onChange(ThemeMode.light);
            },
          ),
          _Segment(
            icon: Icons.dark_mode_rounded,
            selected: value == ThemeMode.dark,
            onTap: () {
              HapticFeedback.selectionClick();
              onChange(ThemeMode.dark);
            },
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fg = selected
        ? (isDark ? Colors.white : AppColors.textPrimary)
        : (isDark ? AppColors.darkTextSecondary : AppColors.textDisabled);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.darkSurfaceAlt : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
                      offset: const Offset(0, 1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
            border: selected
                ? Border.all(
                    color: (isDark ? AppColors.darkBorder : AppColors.border)
                        .withValues(alpha: 0.7),
                  )
                : null,
          ),
          child: Center(
            child: Icon(icon, size: 20, color: fg),
          ),
        ),
      ),
    );
  }
}
