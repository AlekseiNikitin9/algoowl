import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Section header with flex rules flanking an uppercase eyebrow label.
/// Replaces the old "── Your Path ──" string literal.
class SectionHeader extends StatelessWidget {
  final String label;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.label,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.border;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: borderColor)),
          const SizedBox(width: 12),
          Text(
            label.toUpperCase(),
            style: AppTypography.eyebrow.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: borderColor)),
        ],
      ),
    );
  }
}
