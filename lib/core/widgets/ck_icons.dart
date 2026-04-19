import 'package:flutter/material.dart';

/// Phosphor-style single-weight custom icons (24x24, stroke = currentColor).
/// Each variant paints the SVG paths via [CustomPainter] so tint follows
/// text color; filled variants draw closed shapes.
class CkIcon extends StatelessWidget {
  final _IconKind _kind;
  final double size;
  final Color? color;

  const CkIcon._(this._kind, {this.size = 24, this.color, super.key});

  const CkIcon.home({double size = 24, Color? color, Key? key})
      : this._(_IconKind.home, size: size, color: color, key: key);
  const CkIcon.book({double size = 24, Color? color, Key? key})
      : this._(_IconKind.book, size: size, color: color, key: key);
  const CkIcon.trophy({double size = 24, Color? color, Key? key})
      : this._(_IconKind.trophy, size: size, color: color, key: key);
  const CkIcon.user({double size = 24, Color? color, Key? key})
      : this._(_IconKind.user, size: size, color: color, key: key);
  const CkIcon.flame({double size = 24, Color? color, Key? key})
      : this._(_IconKind.flame, size: size, color: color, key: key);
  const CkIcon.bolt({double size = 24, Color? color, Key? key})
      : this._(_IconKind.bolt, size: size, color: color, key: key);
  const CkIcon.play({double size = 24, Color? color, Key? key})
      : this._(_IconKind.play, size: size, color: color, key: key);
  const CkIcon.lock({double size = 24, Color? color, Key? key})
      : this._(_IconKind.lock, size: size, color: color, key: key);
  const CkIcon.check({double size = 24, Color? color, Key? key})
      : this._(_IconKind.check, size: size, color: color, key: key);
  const CkIcon.chevR({double size = 24, Color? color, Key? key})
      : this._(_IconKind.chevR, size: size, color: color, key: key);
  const CkIcon.chevL({double size = 24, Color? color, Key? key})
      : this._(_IconKind.chevL, size: size, color: color, key: key);
  const CkIcon.close({double size = 24, Color? color, Key? key})
      : this._(_IconKind.close, size: size, color: color, key: key);
  const CkIcon.plus({double size = 24, Color? color, Key? key})
      : this._(_IconKind.plus, size: size, color: color, key: key);
  const CkIcon.hint({double size = 24, Color? color, Key? key})
      : this._(_IconKind.hint, size: size, color: color, key: key);
  const CkIcon.reset({double size = 24, Color? color, Key? key})
      : this._(_IconKind.reset, size: size, color: color, key: key);
  const CkIcon.send({double size = 24, Color? color, Key? key})
      : this._(_IconKind.send, size: size, color: color, key: key);
  const CkIcon.run({double size = 24, Color? color, Key? key})
      : this._(_IconKind.run, size: size, color: color, key: key);
  const CkIcon.sun({double size = 24, Color? color, Key? key})
      : this._(_IconKind.sun, size: size, color: color, key: key);
  const CkIcon.moon({double size = 24, Color? color, Key? key})
      : this._(_IconKind.moon, size: size, color: color, key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CkIconPainter(_kind, c),
      ),
    );
  }
}

enum _IconKind {
  home, book, trophy, user, flame, bolt, play, lock, check,
  chevR, chevL, close, plus, hint, reset, send, run, sun, moon,
}

class _CkIconPainter extends CustomPainter {
  final _IconKind kind;
  final Color color;
  _CkIconPainter(this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    canvas.save();
    canvas.scale(scale);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color..style = PaintingStyle.fill;

    switch (kind) {
      case _IconKind.home:
        final p = Path()
          ..moveTo(3, 11)
          ..lineTo(12, 4)
          ..lineTo(21, 11)
          ..lineTo(21, 20)
          ..cubicTo(21, 21.1, 20.1, 22, 19, 22)
          ..lineTo(16, 22)
          ..lineTo(16, 16)
          ..lineTo(8, 16)
          ..lineTo(8, 22)
          ..lineTo(5, 22)
          ..cubicTo(3.9, 22, 3, 21.1, 3, 20)
          ..close();
        canvas.drawPath(p, stroke);
        break;
      case _IconKind.book:
        final p = Path()
          ..moveTo(6, 4)
          ..lineTo(16, 4)
          ..cubicTo(17.66, 4, 19, 5.34, 19, 7)
          ..lineTo(19, 20)
          ..lineTo(8, 20)
          ..cubicTo(6.9, 20, 6, 19.1, 6, 18)
          ..close();
        canvas.drawPath(p, stroke);
        canvas.drawLine(const Offset(6, 4), const Offset(6, 18), stroke);
        canvas.drawLine(const Offset(10, 8), const Offset(15, 8), stroke);
        canvas.drawLine(const Offset(10, 12), const Offset(15, 12), stroke);
        break;
      case _IconKind.trophy:
        final cup = Path()
          ..moveTo(7, 4)
          ..lineTo(17, 4)
          ..lineTo(17, 9)
          ..cubicTo(17, 11.76, 14.76, 14, 12, 14)
          ..cubicTo(9.24, 14, 7, 11.76, 7, 9)
          ..close();
        canvas.drawPath(cup, stroke);
        final lh = Path()
          ..moveTo(7, 6)..lineTo(4, 6)..lineTo(4, 8)
          ..cubicTo(4, 9.66, 5.34, 11, 7, 11);
        canvas.drawPath(lh, stroke);
        final rh = Path()
          ..moveTo(17, 6)..lineTo(20, 6)..lineTo(20, 8)
          ..cubicTo(20, 9.66, 18.66, 11, 17, 11);
        canvas.drawPath(rh, stroke);
        canvas.drawLine(const Offset(9, 18), const Offset(15, 18), stroke);
        canvas.drawLine(const Offset(12, 14), const Offset(12, 18), stroke);
        break;
      case _IconKind.user:
        canvas.drawCircle(const Offset(12, 8), 4, stroke);
        final body = Path()
          ..moveTo(4, 20)
          ..cubicTo(5.5, 16, 8.5, 14, 12, 14)
          ..cubicTo(15.5, 14, 18.5, 16, 20, 20);
        canvas.drawPath(body, stroke);
        break;
      case _IconKind.flame:
        final p = Path()
          ..moveTo(12, 3)
          ..cubicTo(13, 6, 16, 7, 16, 11)
          ..cubicTo(16, 13.2, 14.2, 15, 12, 15)
          ..cubicTo(9.8, 15, 8, 13.2, 8, 11)
          ..cubicTo(8, 9, 9, 8, 9, 6)
          ..cubicTo(10, 8, 12, 7, 12, 3)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case _IconKind.bolt:
        final p = Path()
          ..moveTo(13, 2)
          ..lineTo(4, 14)
          ..lineTo(11, 14)
          ..lineTo(10, 22)
          ..lineTo(19, 10)
          ..lineTo(12, 10)
          ..lineTo(13, 2)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case _IconKind.play:
      case _IconKind.run:
        final p = Path()
          ..moveTo(7, 4)
          ..lineTo(7, 20)
          ..lineTo(20, 12)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case _IconKind.lock:
        final shackle = Path()
          ..moveTo(6, 11)
          ..lineTo(6, 8)
          ..arcToPoint(const Offset(18, 8), radius: const Radius.circular(6))
          ..lineTo(18, 11);
        canvas.drawPath(shackle, stroke);
        canvas.drawRect(const Rect.fromLTWH(5, 11, 14, 10), stroke);
        break;
      case _IconKind.check:
        final p = Path()
          ..moveTo(4, 12)
          ..lineTo(9, 17)
          ..lineTo(20, 6);
        canvas.drawPath(p, stroke);
        break;
      case _IconKind.chevR:
        final p = Path()..moveTo(9, 6)..lineTo(15, 12)..lineTo(9, 18);
        canvas.drawPath(p, stroke);
        break;
      case _IconKind.chevL:
        final p = Path()..moveTo(15, 6)..lineTo(9, 12)..lineTo(15, 18);
        canvas.drawPath(p, stroke);
        break;
      case _IconKind.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), stroke);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), stroke);
        break;
      case _IconKind.plus:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), stroke);
        break;
      case _IconKind.hint:
        final bulb = Path()
          ..moveTo(12, 2)
          ..arcToPoint(const Offset(8, 15), radius: const Radius.circular(7), clockwise: false)
          ..lineTo(8, 18)
          ..lineTo(16, 18)
          ..lineTo(16, 15)
          ..arcToPoint(const Offset(12, 2), radius: const Radius.circular(7), clockwise: false)
          ..close();
        canvas.drawPath(bulb, stroke);
        canvas.drawLine(const Offset(9, 21), const Offset(15, 21), stroke);
        break;
      case _IconKind.reset:
        final arc = Path()
          ..addArc(Rect.fromCircle(center: const Offset(12, 12), radius: 8), -1.9, 5.2);
        canvas.drawPath(arc, stroke);
        final ticker = Path()..moveTo(4, 4)..lineTo(4, 9)..lineTo(9, 9);
        canvas.drawPath(ticker, stroke);
        break;
      case _IconKind.send:
        final p = Path()
          ..moveTo(4, 12)
          ..lineTo(20, 4)
          ..lineTo(16, 20)
          ..lineTo(12, 14)
          ..lineTo(4, 12)
          ..close();
        canvas.drawPath(p, stroke);
        break;
      case _IconKind.sun:
        canvas.drawCircle(const Offset(12, 12), 4, stroke);
        for (final line in const [
          [Offset(12, 4), Offset(12, 6)],
          [Offset(12, 18), Offset(12, 20)],
          [Offset(4, 12), Offset(2, 12)],
          [Offset(22, 12), Offset(20, 12)],
          [Offset(5.6, 5.6), Offset(4.2, 4.2)],
          [Offset(19.8, 19.8), Offset(18.4, 18.4)],
          [Offset(5.6, 18.4), Offset(4.2, 19.8)],
          [Offset(19.8, 4.2), Offset(18.4, 5.6)],
        ]) {
          canvas.drawLine(line[0], line[1], stroke);
        }
        break;
      case _IconKind.moon:
        final p = Path()
          ..moveTo(20, 14)
          ..arcToPoint(const Offset(9, 3),
              radius: const Radius.circular(9), clockwise: false)
          ..arcToPoint(const Offset(20, 14),
              radius: const Radius.circular(9), clockwise: false)
          ..close();
        canvas.drawPath(p, stroke);
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CkIconPainter old) => old.kind != kind || old.color != color;
}
