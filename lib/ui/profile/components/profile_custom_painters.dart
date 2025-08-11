import 'package:flutter/material.dart';
import 'dart:math' show cos, sin;

/// キラキラエフェクト用のカスタムペインター
class SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // キラキラを描画
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      _drawStar(canvas, paint, Offset(x, y), 3);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159) / 5;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ハートエフェクト用のカスタムペインター
class HeartsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // ハートを描画
    for (int i = 0; i < 15; i++) {
      final x = (i * 41) % size.width;
      final y = (i * 29) % size.height;
      _drawHeart(canvas, paint, Offset(x, y), 4);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size);
    path.cubicTo(
      center.dx - size,
      center.dy - size / 2,
      center.dx - size * 2,
      center.dy - size,
      center.dx,
      center.dy - size / 2,
    );
    path.cubicTo(
      center.dx + size * 2,
      center.dy - size,
      center.dx + size,
      center.dy - size / 2,
      center.dx,
      center.dy + size,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ドットパターン用のカスタムペインター
class DotPatternPainter extends CustomPainter {
  final Color color;
  final double dotSize;
  final double spacing;

  DotPatternPainter({
    this.color = Colors.white,
    this.dotSize = 2.0,
    this.spacing = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ストライプパターン用のカスタムペインター
class StripePatternPainter extends CustomPainter {
  final Color color;
  final double stripeWidth;

  StripePatternPainter({
    this.color = Colors.white,
    this.stripeWidth = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += stripeWidth * 2) {
      final rect = Rect.fromLTWH(x, 0, stripeWidth, size.height);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
