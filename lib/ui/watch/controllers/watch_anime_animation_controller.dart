import 'package:flutter/material.dart';

/// アニメ詳細画面のアニメーション管理コントローラー
class WatchAnimeAnimationController {
  late AnimationController fadeController;
  late AnimationController slideController;
  late AnimationController particleController;
  late AnimationController favoriteController;
  
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<double> favoriteAnimation;

  /// アニメーションの初期化
  void initialize(TickerProvider vsync) {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    );
    
    slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );

    particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: vsync,
    )..repeat();

    favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
    
    // アニメーションの設定
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    ));
    
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.elasticOut,
    ));

    favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: favoriteController,
      curve: Curves.elasticOut,
    ));
  }

  /// アニメーションの開始
  void startAnimations() {
    fadeController.forward();
    slideController.forward();
  }

  /// お気に入りアニメーションの実行
  Future<void> playFavoriteAnimation() async {
    await favoriteController.forward();
    favoriteController.reverse();
  }

  /// アニメーションコントローラーの破棄
  void dispose() {
    fadeController.dispose();
    slideController.dispose();
    particleController.dispose();
    favoriteController.dispose();
  }
}

/// アニメーション状態を提供するウィジェット
class AnimatedWatchAnimeContainer extends StatelessWidget {
  final WatchAnimeAnimationController animationController;
  final Widget child;

  const AnimatedWatchAnimeContainer({
    Key? key,
    required this.animationController,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController.fadeAnimation,
      child: SlideTransition(
        position: animationController.slideAnimation,
        child: child,
      ),
    );
  }
}

/// お気に入りボタンのアニメーション用ウィジェット
class AnimatedFavoriteIcon extends StatelessWidget {
  final WatchAnimeAnimationController animationController;
  final bool isFavorite;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AnimatedFavoriteIcon({
    Key? key,
    required this.animationController,
    required this.isFavorite,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController.favoriteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: animationController.favoriteAnimation.value,
          child: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFavorite ? Colors.pink : Colors.grey,
                      ),
                    ),
                  )
                : Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink[400] : Colors.grey[600],
                  ),
          ),
        );
      },
    );
  }
} 