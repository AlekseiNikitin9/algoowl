import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary gradient card with an animated conic hue-shift overlay.
/// Used for "Continue learning" style CTAs.
class PrimaryCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const PrimaryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  State<PrimaryCard> createState() => _PrimaryCardState();
}

class _PrimaryCardState extends State<PrimaryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: AnimatedBuilder(
        animation: _c,
        child: Padding(padding: widget.padding, child: widget.child),
        builder: (_, child) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.12),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.14),
                offset: const Offset(0, 6),
                blurRadius: 16,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _ConicShimmerPainter(_c.value * 2 * math.pi),
                    ),
                  ),
                ),
                child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConicShimmerPainter extends CustomPainter {
  final double rotation;
  _ConicShimmerPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.longestSide;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final shader = SweepGradient(
      transform: GradientRotation(rotation),
      colors: [
        Colors.white.withValues(alpha: 0),
        Colors.white.withValues(alpha: 0.18),
        Colors.white.withValues(alpha: 0),
        const Color(0xFFC8E4FF).withValues(alpha: 0.22),
        Colors.white.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.15, 0.4, 0.55, 0.85],
    ).createShader(rect);
    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.overlay;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_ConicShimmerPainter old) => old.rotation != rotation;
}

/// Neutral card — surface, hairline border, soft shadow.
class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadowColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : const Color(0xFF1A1F2E);
    final card = Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outline),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: card,
    );
  }
}
