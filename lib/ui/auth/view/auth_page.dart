// 遷移先
import 'package:animeishi/ui/auth/view/email_login_page.dart';
import 'package:animeishi/ui/auth/view/email_sign_up_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';

// コンポーネント
import 'package:animeishi/ui/auth/components/auth_logout_handler.dart';
import 'package:animeishi/ui/auth/components/auth_widgets.dart';
import 'package:animeishi/ui/auth/components/auth_animations.dart';

// 標準
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // パーティクルアニメーション用
  late AuthAnimationController _animationController;

  // ログアウト状態管理
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    // パーティクル初期化
    _animationController = AuthAnimationController();
    _animationController.initializeParticles();
    _animationController.startAnimation(() {
      if (mounted) {
        setState(() {});
      }
    });

    // フェードインアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // スライドアニメーション
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // アニメーション開始
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _setLoggingOut(bool value) {
    setState(() {
      _isLoggingOut = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション
          AuthWidgets.buildBackgroundGradient(),

          // パーティクルアニメーション
          _animationController.buildParticleAnimation(size),

          // メインコンテンツ
          SafeArea(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ロゴ・タイトル部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              AuthWidgets.buildAppIcon(
                                  isSmallScreen: isSmallScreen),
                              SizedBox(height: isSmallScreen ? 32 : 40),
                              AuthWidgets.buildAppTitle(
                                  isSmallScreen: isSmallScreen),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 48 : 64),

                      // ボタン群
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              // ログインボタン
                              AuthWidgets.buildAnimatedButton(
                                text: 'ログイン',
                                icon: Icons.login_rounded,
                                gradientColors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                                onPressed: _navigateToLogin,
                              ),

                              SizedBox(height: 20),

                              // 新規登録ボタン
                              AuthWidgets.buildAnimatedButton(
                                text: '新規登録',
                                icon: Icons.person_add_rounded,
                                gradientColors: [
                                  Color(0xFF48BB78),
                                  Color(0xFF38A169),
                                ],
                                onPressed: _navigateToSignUp,
                              ),

                              SizedBox(height: isSmallScreen ? 40 : 48),

                              // ログアウトボタン
                              AuthLogoutHandler.buildLogoutButton(
                                context: context,
                                isLoggingOut: _isLoggingOut,
                                setLoggingOut: _setLoggingOut,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() async {
    // 現在のログイン状態をチェック
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // 既にログインしている場合はホーム画面に直接遷移
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      // ログインしていない場合はログイン画面に遷移
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              EmailLoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EmailSignUpPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
