import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum OwlButtonVariant { primary, success, ghost }

/// Solid pill CTA with a clean color gradient, crisp border, and layered shadow.
class OwlButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final OwlButtonVariant variant;
  final Widget? leading;

  const OwlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = OwlButtonVariant.primary,
    this.leading,
  });

  const OwlButton.success({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leading,
  }) : variant = OwlButtonVariant.success;

  const OwlButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.leading,
  }) : variant = OwlButtonVariant.ghost;

  @override
  State<OwlButton> createState() => _OwlButtonState();
}

class _OwlButtonState extends State<OwlButton> {
  bool _isPressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  List<Color> get _gradientColors {
    return switch (widget.variant) {
      OwlButtonVariant.primary => const [
          Color(0xFF3AADFF), // lighter electric blue
          Color(0xFF0B7FE8), // deeper blue
        ],
      OwlButtonVariant.success => const [
          Color(0xFF3EE08B), // lighter green
          Color(0xFF15995A), // deeper green
        ],
      OwlButtonVariant.ghost => [Colors.transparent, Colors.transparent],
    };
  }

  Color get _shadowColor => switch (widget.variant) {
        OwlButtonVariant.primary => const Color(0xFF0066CC),
        OwlButtonVariant.success => AppColors.successDark,
        OwlButtonVariant.ghost => Colors.transparent,
      };

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == OwlButtonVariant.ghost;
    final textColor = isGhost ? Theme.of(context).colorScheme.onSurface : Colors.white;

    return Opacity(
      opacity: _enabled ? 1.0 : 0.45,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => _press() : null,
        onTapUp: _enabled ? (_) => _release() : null,
        onTapCancel: _enabled ? _release : null,
        onTap: _enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              gradient: isGhost
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _gradientColors,
                    ),
              color: isGhost ? Colors.transparent : null,
              border: isGhost
                  ? Border.all(color: Theme.of(context).colorScheme.outline)
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1,
                    ),
              boxShadow: isGhost
                  ? null
                  : [
                      BoxShadow(
                        color: _shadowColor.withValues(alpha: 0.25),
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                      ),
                      BoxShadow(
                        color: _shadowColor.withValues(
                            alpha: _isPressed ? 0.22 : 0.35),
                        offset: Offset(0, _isPressed ? 4 : 10),
                        blurRadius: _isPressed ? 14 : 24,
                      ),
                    ],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: widget.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.leading != null) ...[
                        widget.leading!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.01 * 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _press() => setState(() => _isPressed = true);
  void _release() => setState(() => _isPressed = false);
}
