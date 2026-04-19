import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum OwlButtonVariant { primary, success, ghost }

/// Glass pill CTA with internal gradient, soft layered shadow, and inner highlight.
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

  @override
  Widget build(BuildContext context) {
    final isGhost = widget.variant == OwlButtonVariant.ghost;
    final baseColor = switch (widget.variant) {
      OwlButtonVariant.primary => AppColors.primary,
      OwlButtonVariant.success => AppColors.success,
      OwlButtonVariant.ghost => Colors.transparent,
    };
    final shadowColor = switch (widget.variant) {
      OwlButtonVariant.primary => const Color(0xFF0066CC),
      OwlButtonVariant.success => AppColors.successDark,
      OwlButtonVariant.ghost => Colors.transparent,
    };
    final textColor = isGhost ? Theme.of(context).colorScheme.onSurface : Colors.white;

    return GestureDetector(
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
        scale: _isPressed ? 0.98 : 1,
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
                    colors: [
                      Colors.white.withValues(alpha: 0.14),
                      Colors.white.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.08),
                    ],
                    stops: const [0, 0.45, 1],
                  ),
            color: _enabled ? baseColor : baseColor.withValues(alpha: 0.4),
            border: isGhost
                ? Border.all(color: Theme.of(context).colorScheme.outline)
                : null,
            boxShadow: isGhost || !_enabled
                ? null
                : [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.14),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: shadowColor.withValues(alpha: _isPressed ? 0.18 : 0.22),
                      offset: Offset(0, _isPressed ? 4 : 10),
                      blurRadius: _isPressed ? 14 : 28,
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
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.01 * 16,
                        color: _enabled
                            ? textColor
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _press() => setState(() => _isPressed = true);
  void _release() => setState(() => _isPressed = false);
}
