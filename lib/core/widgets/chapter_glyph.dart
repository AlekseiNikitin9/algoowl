import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum GlyphKind { array, hash, pointer, window, stack, search, tree, graph, neural }

/// Geometric diagram glyphs that hint at each chapter's theme.
/// Mirrors codekata_redesign/src/icons.jsx ChapterGlyph.
class ChapterGlyph extends StatelessWidget {
  final GlyphKind kind;
  final double size;
  final Color? color;

  const ChapterGlyph({
    super.key,
    required this.kind,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ChapterGlyphPainter(kind, color ?? AppColors.primary),
      ),
    );
  }
}

class _ChapterGlyphPainter extends CustomPainter {
  final GlyphKind kind;
  final Color color;
  _ChapterGlyphPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 48;
    canvas.save();
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final thin = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color..style = PaintingStyle.fill;

    switch (kind) {
      case GlyphKind.array:
        for (var i = 0; i < 5; i++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(4 + i * 8.0, 18, 7, 12),
            const Radius.circular(1.5),
          );
          canvas.drawRRect(rect, stroke);
          if (i == 1) {
            canvas.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.14));
          }
        }
        break;
      case GlyphKind.hash:
        canvas.drawLine(const Offset(18, 8), const Offset(14, 40), stroke);
        canvas.drawLine(const Offset(34, 8), const Offset(30, 40), stroke);
        canvas.drawLine(const Offset(8, 18), const Offset(40, 18), stroke);
        canvas.drawLine(const Offset(6, 30), const Offset(38, 30), stroke);
        break;
      case GlyphKind.pointer:
        canvas.drawLine(const Offset(6, 24), const Offset(42, 24), stroke);
        canvas.drawCircle(const Offset(14, 24), 3, fill);
        canvas.drawCircle(const Offset(34, 24), 3, fill);
        for (final cx in [14.0, 34.0]) {
          final arrow = Path()
            ..moveTo(cx, 30)
            ..lineTo(cx - 3, 34)
            ..lineTo(cx + 3, 34)
            ..close();
          canvas.drawPath(arrow, fill);
        }
        break;
      case GlyphKind.window:
        for (var i = 0; i < 6; i++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(4 + i * 6.5, 18, 5.5, 12),
            const Radius.circular(1),
          );
          canvas.drawRRect(rect, thin);
        }
        final winRect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(10.5, 16, 18.5, 16),
          const Radius.circular(2),
        );
        canvas.drawRRect(winRect, Paint()..color = color.withValues(alpha: 0.10));
        canvas.drawRRect(
          winRect,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        break;
      case GlyphKind.stack:
        for (var i = 0; i < 3; i++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(10, 10 + i * 9.0, 28, 7),
            const Radius.circular(1.5),
          );
          canvas.drawRRect(
            rect,
            Paint()..color = color.withValues(alpha: 0.04 + i * 0.06),
          );
          canvas.drawRRect(rect, stroke);
        }
        break;
      case GlyphKind.search:
        canvas.drawLine(const Offset(4, 24), const Offset(44, 24), stroke);
        const points = <double>[6, 14, 22, 30, 38];
        for (var i = 0; i < points.length; i++) {
          canvas.drawCircle(
            Offset(points[i], 24),
            2,
            Paint()..color = i == 2 ? color : const Color(0xFFD8E0EF),
          );
        }
        final arrow = Path()
          ..moveTo(22, 30)
          ..lineTo(19, 35)
          ..lineTo(25, 35)
          ..close();
        canvas.drawPath(arrow, fill);
        break;
      case GlyphKind.tree:
        canvas.drawLine(const Offset(24, 12), const Offset(12, 26), thin);
        canvas.drawLine(const Offset(24, 12), const Offset(36, 26), thin);
        canvas.drawLine(const Offset(12, 26), const Offset(6, 40), thin);
        canvas.drawLine(const Offset(12, 26), const Offset(18, 40), thin);
        canvas.drawLine(const Offset(36, 26), const Offset(30, 40), thin);
        canvas.drawLine(const Offset(36, 26), const Offset(42, 40), thin);
        for (final p in const [
          Offset(24, 12), Offset(12, 26), Offset(36, 26),
          Offset(6, 40), Offset(18, 40), Offset(30, 40), Offset(42, 40),
        ]) {
          canvas.drawCircle(p, 3, fill);
        }
        break;
      case GlyphKind.graph:
        final path = Path()
          ..moveTo(8, 8)..lineTo(24, 20)..lineTo(40, 8)
          ..moveTo(8, 8)..lineTo(20, 40)
          ..moveTo(24, 20)..lineTo(20, 40)
          ..moveTo(24, 20)..lineTo(38, 38)
          ..moveTo(40, 8)..lineTo(38, 38);
        canvas.drawPath(path, thin);
        for (final p in const [
          Offset(8, 8), Offset(24, 20), Offset(40, 8),
          Offset(20, 40), Offset(38, 38),
        ]) {
          canvas.drawCircle(p, 3.5, fill);
        }
        break;
      case GlyphKind.neural:
        final lineThin = Paint()
          ..color = color.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
        const layerA = <double>[12, 24, 36];
        const layerB = <double>[10, 20, 30, 40];
        const layerC = <double>[16, 32];
        for (final y1 in layerA) {
          for (final y2 in layerB) {
            canvas.drawLine(Offset(8, y1), Offset(24, y2), lineThin);
          }
        }
        for (final y1 in layerB) {
          for (final y2 in layerC) {
            canvas.drawLine(Offset(24, y1), Offset(40, y2), lineThin);
          }
        }
        for (final y in layerA) {
          canvas.drawCircle(Offset(8, y), 2.5, fill);
        }
        for (final y in layerB) {
          canvas.drawCircle(Offset(24, y), 2.5, fill);
        }
        for (final y in layerC) {
          canvas.drawCircle(Offset(40, y), 2.5, fill);
        }
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChapterGlyphPainter old) =>
      old.kind != kind || old.color != color;
}

/// Chapter tiers (replaces emoji milestones) — Rookie → Junior → Senior → Principal.
class ChapterTier {
  final String name;
  final GlyphKind glyph;
  final int startIndex;
  final int endIndexExclusive;
  const ChapterTier(this.name, this.glyph, this.startIndex, this.endIndexExclusive);
}

const List<ChapterTier> kChapterTiers = [
  ChapterTier('Rookie', GlyphKind.array, 0, 1),
  ChapterTier('Junior', GlyphKind.hash, 1, 4),
  ChapterTier('Senior', GlyphKind.tree, 4, 8),
  ChapterTier('Principal', GlyphKind.neural, 8, 14),
];
