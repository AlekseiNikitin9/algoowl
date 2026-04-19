import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Apple-style glass top bar: backdrop blur + subtle tint + hairline border.
/// Intended to be placed at the top of a stack with the scroll view underneath.
class GlassBar extends StatelessWidget {
  final Widget child;
  final double height;

  const GlassBar({
    super.key,
    required this.child,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark
        ? AppColors.darkBg.withValues(alpha: 0.72)
        : AppColors.bg.withValues(alpha: 0.72);
    final border = isDark
        ? AppColors.darkBorder.withValues(alpha: 0.35)
        : AppColors.borderStrong.withValues(alpha: 0.35);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: height + MediaQuery.paddingOf(context).top,
          padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
          decoration: BoxDecoration(
            color: tint,
            border: Border(bottom: BorderSide(color: border, width: 0.5)),
          ),
          child: child,
        ),
      ),
    );
  }
}
