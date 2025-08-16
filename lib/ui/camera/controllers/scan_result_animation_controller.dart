import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// QRスキャン結果画面のアニメーション管理コントローラー
class ScanResultAnimationController {
  late AnimationController fadeController;
  late AnimationController slideController;
  late AnimationController celebrationController;
  late AnimationController particleController;

  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> celebrationAnimation;
  late Animation<double> scaleAnimation;

  /// アニメーションの初期化
  void initialize(TickerProvider vsync) {
    // 成功時のバイブレーション
    HapticFeedback.lightImpact();

    fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: vsync,
    );

    slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: vsync,
    );

    celebrationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: vsync,
    );

    particleController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: vsync,
    )..repeat();

    // アニメーションの設定
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    ));

    slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.elasticOut,
    ));

    celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: celebrationController,
      curve: Curves.elasticOut,
    ));

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: celebrationController,
      curve: Curves.elasticOut,
    ));
  }

  /// アニメーションの開始
  void startAnimations() {
    fadeController.forward();
    slideController.forward();

    // 少し遅れてお祝いアニメーション開始
    Future.delayed(Duration(milliseconds: 300), () {
      celebrationController.forward();
    });
  }

  /// アニメーションコントローラーの破棄
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    celebrationController.dispose();
    particleController.dispose();
  }
}

/// アニメーション状態を提供するウィジェット
class AnimatedScanResultContainer extends StatelessWidget {
  final ScanResultAnimationController animationController;
  final Widget child;

  const AnimatedScanResultContainer({
    Key? key,
    required this.animationController,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController.fadeAnimation,
      child: child,
    );
  }
}

/// スライドアニメーション付きコンテナ
class SlideAnimatedContainer extends StatelessWidget {
  final ScanResultAnimationController animationController;
  final Widget child;

  const SlideAnimatedContainer({
    Key? key,
    required this.animationController,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: animationController.slideAnimation,
      child: child,
    );
  }
}

/// セレブレーションアニメーション付きウィジェット
class CelebrationAnimatedWidget extends StatelessWidget {
  final ScanResultAnimationController animationController;
  final Widget child;

  const CelebrationAnimatedWidget({
    Key? key,
    required this.animationController,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController.celebrationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: animationController.scaleAnimation.value,
          child: this.child,
        );
      },
    );
  }
}
