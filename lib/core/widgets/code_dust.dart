import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Code-dust celebration — tiny mono-font glyphs fly upward when a submission passes.
/// Pure particle system, no images. Replaces confetti.
class CodeDustOverlay extends StatefulWidget {
  final bool show;
  final int particleCount;

  const CodeDustOverlay({
    super.key,
    required this.show,
    this.particleCount = 22,
  });

  @override
  State<CodeDustOverlay> createState() => _CodeDustOverlayState();
}

class _CodeDustOverlayState extends State<CodeDustOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _rng = math.Random();
  late List<_Particle> _particles;

  static const _glyphs = ['{', '}', '[', ']', '(', ')', '<', '>', ';', '.', '0', '1'];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _particles = _seed();
    if (widget.show) _c.forward(from: 0);
  }

  @override
  void didUpdateWidget(covariant CodeDustOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _particles = _seed();
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  List<_Particle> _seed() => List.generate(
        widget.particleCount,
        (_) => _Particle(
          glyph: _glyphs[_rng.nextInt(_glyphs.length)],
          dx: (_rng.nextDouble() - 0.5) * 260,
          dy: -(60 + _rng.nextDouble() * 140),
          startX: _rng.nextDouble(),
          startY: 0.55 + _rng.nextDouble() * 0.25,
          delay: _rng.nextDouble() * 0.3,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _DustPainter(_particles, _c.value),
        ),
      ),
    );
  }
}

class _Particle {
  final String glyph;
  final double dx, dy;
  final double startX, startY;
  final double delay;
  _Particle({
    required this.glyph,
    required this.dx,
    required this.dy,
    required this.startX,
    required this.startY,
    required this.delay,
  });
}

class _DustPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _DustPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final localT = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      double opacity;
      if (localT < 0.15) {
        opacity = localT / 0.15;
      } else {
        opacity = 1 - (localT - 0.15) / 0.85;
      }
      final scale = 0.6 + 0.4 * eased;
      final sx = p.startX * size.width;
      final sy = p.startY * size.height;
      final x = sx + p.dx * eased;
      final y = sy + p.dy * eased;
      final tp = TextPainter(
        text: TextSpan(
          text: p.glyph,
          style: GoogleFonts.jetBrainsMono(
            color: AppColors.success.withValues(alpha: opacity.clamp(0, 1)),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_DustPainter old) => old.t != t;
}
