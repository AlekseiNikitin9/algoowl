import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Small pill chip — 30px tall, border, 13px label.
class CkChip extends StatelessWidget {
  final Widget? leading;
  final String label;
  final Color? background;
  final Color? foreground;
  final VoidCallback? onTap;

  const CkChip({
    super.key,
    this.leading,
    required this.label,
    this.background,
    this.foreground,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = background ?? scheme.surface;
    final fg = foreground ?? scheme.onSurface;
    final pill = Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: scheme.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: fg, size: 14),
              child: leading!,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTypography.label.copyWith(color: fg, fontSize: 13),
          ),
        ],
      ),
    );
    if (onTap == null) return pill;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: pill,
    );
  }
}
