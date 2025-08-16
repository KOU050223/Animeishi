import 'package:flutter/material.dart';
import 'dart:math';

class AnimationPainter extends CustomPainter {
  List<Particle> particles;
  AnimationPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      canvas.drawCircle(
        particle.pos,
        particle.radius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = particle.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  final Color color = _getRandomColor();
  final double radius = _getRandomVal(2, 6);

  double dx = _getRandomVal(-0.2, 0.2);
  double dy = _getRandomVal(-0.2, 0.2);

  late double x = _getRandomVal(0, 1000);
  late double y = _getRandomVal(0, 800);
  late Offset pos = Offset(x, y);

  void moveParticle() {
    Offset nextPos = pos + Offset(dx, dy);
    if (nextPos.dx < 0 ||
        nextPos.dx > 1000 ||
        nextPos.dy < 0 ||
        nextPos.dy > 800) {
      dx = -dx;
      dy = -dy;
      nextPos = pos + Offset(dx, dy);
    }
    pos = nextPos;
  }

  static Color _getRandomColor() {
    final colorList = [
      Color(0xFF667eea).withOpacity(0.06),
      Color(0xFF764ba2).withOpacity(0.08),
      Color(0xFFf093fb).withOpacity(0.05),
      Color(0xFF4FD1C7).withOpacity(0.07),
      Colors.white.withOpacity(0.4),
    ];
    final rnd = Random();
    return colorList[rnd.nextInt(colorList.length)];
  }

  static double _getRandomVal(double min, double max) {
    final rnd = Random();
    return rnd.nextDouble() * (max - min) + min;
  }
}
