import 'package:flutter/material.dart';
import 'dart:math' as math;

class SNSParticlePainter extends CustomPainter {
  final double animationValue;
  SNSParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);

    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);

      final animatedX = x + math.sin(offset + i * 0.5) * 15;
      final animatedY = y + math.cos(offset + i * 0.3) * 15;

      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 3 * math.pi + i) * 2;

      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.5),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.5),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.5),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.5),
        const Color(0xFF667EEA).withOpacity(opacity * 0.3),
        const Color(0xFF764BA2).withOpacity(opacity * 0.3),
      ][i % 6];

      canvas.drawCircle(
        Offset(animatedX, animatedY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
