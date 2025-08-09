import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  Color color;

  Particle()
      : x = Random().nextDouble() * 400,
        y = Random().nextDouble() * 800,
        vx = (Random().nextDouble() - 0.5) * 2,
        vy = (Random().nextDouble() - 0.5) * 2,
        life = Random().nextDouble(),
        color = Color.fromRGBO(
          200 + Random().nextInt(56),
          200 + Random().nextInt(56),
          255,
          0.3 + Random().nextDouble() * 0.4,
        );

  void moveParticle() {
    x += vx;
    y += vy;
    life -= 0.01;

    if (x < 0 || x > 400) vx = -vx;
    if (y < 0 || y > 800) vy = -vy;
    if (life <= 0) {
      life = 1.0;
      x = Random().nextDouble() * 400;
      y = Random().nextDouble() * 800;
    }
  }
}

class AnimationPainter extends CustomPainter {
  List<Particle> particles;

  AnimationPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color.withOpacity(particle.life * 0.3);
      canvas.drawCircle(
        Offset(particle.x * size.width / 400, particle.y * size.height / 800),
        2 + particle.life * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class AuthAnimationController {
  late Timer timer;
  late List<Particle> particles;

  void initializeParticles() {
    particles = List<Particle>.generate(50, (index) => Particle());
  }

  void startAnimation(VoidCallback onUpdate) {
    const duration = Duration(milliseconds: 1000 ~/ 60);
    timer = Timer.periodic(duration, (timer) {
      for (var element in particles) {
        element.moveParticle();
      }
      onUpdate();
    });
  }

  void dispose() {
    timer.cancel();
  }

  Widget buildParticleAnimation(Size size) {
    return CustomPaint(
      size: size,
      painter: AnimationPainter(particles),
    );
  }
} 