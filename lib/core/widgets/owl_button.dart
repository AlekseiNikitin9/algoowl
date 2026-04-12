import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Duolingo-style 3D primary button with press animation.
class OwlButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? shadowColor;

  const OwlButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.shadowColor,
  });

  @override
  State<OwlButton> createState() => _OwlButtonState();
}

class _OwlButtonState extends State<OwlButton> {
  bool _isPressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  Color get _bg => widget.backgroundColor ?? AppColors.primary;
  Color get _fg => widget.foregroundColor ?? AppColors.textOnPrimary;
  Color get _shadow => widget.shadowColor ?? AppColors.primaryDark;

  @override
  Widget build(BuildContext context) {
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
      child: AnimatedContainer(
        duration: _isPressed
            ? const Duration(milliseconds: 80)
            : const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        height: 52,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: _enabled ? _bg : Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          boxShadow: _isPressed || !_enabled
              ? []
              : [
                  BoxShadow(
                    color: _shadow,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _fg,
                ),
              )
            : Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: _enabled ? _fg : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
      ),
    );
  }

  void _press() => setState(() => _isPressed = true);
  void _release() => setState(() => _isPressed = false);
}
