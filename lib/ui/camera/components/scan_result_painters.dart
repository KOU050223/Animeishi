import 'package:flutter/material.dart';
import 'dart:math' as math;

/// セレブレーション用パーティクルペインター
class CelebrationParticlePainter extends CustomPainter {
  final double animationValue;

  CelebrationParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);

    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);

      final animatedX = x + math.sin(offset + i) * 8;
      final animatedY = y + math.cos(offset + i) * 8;

      final opacity = (math.sin(animationValue * 3 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 5 * math.pi + i) * 1.5;

      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.7),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.7),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.7),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.7),
        const Color(0xFF667EEA).withOpacity(opacity * 0.5),
        const Color(0xFF764BA2).withOpacity(opacity * 0.5),
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
class ScanResultParticleBackground extends StatelessWidget {
  final AnimationController animationController;

  const ScanResultParticleBackground({
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
            painter: CelebrationParticlePainter(animationController.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

/// サクセスエフェクト用ペインター
class SuccessEffectPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;

  SuccessEffectPainter({
    required this.animationValue,
    this.primaryColor = const Color(0xFF667EEA),
    this.secondaryColor = const Color(0xFF764BA2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);

    // 成功時のリング効果
    for (int i = 0; i < 3; i++) {
      final ringProgress = (animationValue + i * 0.3) % 1.0;
      final ringRadius = ringProgress * math.min(size.width, size.height) * 0.6;
      final ringOpacity = (1.0 - ringProgress) * 0.3;

      paint.color =
          (i % 2 == 0 ? primaryColor : secondaryColor).withOpacity(ringOpacity);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2.0;

      canvas.drawCircle(center, ringRadius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
