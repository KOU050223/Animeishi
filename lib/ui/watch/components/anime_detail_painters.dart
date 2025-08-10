import 'package:flutter/material.dart';
import 'dart:math' as math;

/// アニメ詳細画面のパーティクルアニメーション用カスタムペインター
class AnimeDetailParticlePainter extends CustomPainter {
  final double animationValue;

  AnimeDetailParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);

      final animatedX = x + math.sin(offset + i * 0.3) * 20;
      final animatedY = y + math.cos(offset + i * 0.5) * 20;

      final opacity = (math.sin(animationValue * 1.5 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 2 * math.pi + i) * 2.5;

      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.4),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.4),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.4),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.4),
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

/// パーティクル背景ウィジェット
class ParticleBackgroundWidget extends StatelessWidget {
  final AnimationController animationController;

  const ParticleBackgroundWidget({
    Key? key,
    required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimeDetailParticlePainter(animationController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}
