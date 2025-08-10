import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/components/email_login_validation.dart';
import 'package:animeishi/ui/auth/components/email_login_dialogs.dart';
import 'package:animeishi/ui/auth/components/email_login_widgets.dart';
import 'package:animeishi/ui/auth/components/auth_widgets.dart';
import 'package:animeishi/config/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  String errorMessage = '';
  bool isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late Timer timer;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();

    particles = List<Particle>.generate(40, (index) => Particle());

    const duration = Duration(milliseconds: 16);
    timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          for (var element in particles) {
            element.moveParticle();
          }
        });
      }
    });

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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    timer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailError = EmailLoginValidation.validateEmail(emailController.text);
    final passwordError =
        EmailLoginValidation.validatePassword(passwordController.text);

    if (emailError != null || passwordError != null) {
      EmailLoginDialogs.showValidationDialog(
          context, emailError, passwordError);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final User? user = (await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text))
          .user;

      if (user != null) {
        if (FeatureFlags.enableDebugLogs) {
          print("ログインしました ${user.email}, ${user.uid}");
        }

        EmailLoginDialogs.showSuccessMessage(context);

        await Future.delayed(Duration(milliseconds: 1500));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      if (FeatureFlags.enableDebugLogs) {
        print('ログインエラー: $e');
      }

      setState(() {
        errorMessage =
            EmailLoginValidation.getFirebaseErrorMessage(e.toString());
      });

      EmailLoginDialogs.showErrorDialog(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _testLogin() async {
    emailController.text = 'test@test.com';
    passwordController.text = 'password';
    await _login();
  }

  Future<void> _resetPassword() async {
    final emailError = EmailLoginValidation.validateEmail(emailController.text);

    if (emailError != null) {
      EmailLoginDialogs.showValidationDialog(context, emailError, null);
      return;
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());

      EmailLoginDialogs.showInfoDialog(
        context,
        'パスワードリセット',
        '${emailController.text}へパスワードリセット用のメールを送信しました',
        Icons.email_outlined,
        Colors.blue,
      );
    } catch (e) {
      EmailLoginDialogs.showErrorDialog(context, 'パスワードリセットメールの送信に失敗しました');
    }
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
          CustomPaint(
            size: size,
            painter: AnimationPainter(particles),
          ),

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
                      // 戻るボタン
                      AuthWidgets.buildBackButton(
                        onPressed: () => Navigator.of(context).pop(),
                      ),

                      // タイトル部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AuthWidgets.buildPageTitle(
                            title: 'ログイン',
                            subtitle: 'アカウントにサインインしてください',
                            icon: Icons.login_rounded,
                            iconColors: [
                              Color(0xFF667eea).withOpacity(0.8),
                              Color(0xFF764ba2).withOpacity(0.9),
                            ],
                            isSmallScreen: isSmallScreen,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 40 : 60),

                      // フォーム部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // メールアドレス入力
                            EmailLoginWidgets.buildInputField(
                              controller: emailController,
                              label: 'メールアドレス',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            SizedBox(height: 20),

                            // パスワード入力
                            EmailLoginWidgets.buildInputField(
                              controller: passwordController,
                              label: 'パスワード',
                              icon: Icons.lock_outline,
                              obscureText: hidePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF718096),
                                ),
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                              ),
                            ),

                            SizedBox(height: 32),

                            // ログインボタン
                            EmailLoginWidgets.buildLoginButton(
                              isLoading: isLoading,
                              onPressed: _login,
                            ),

                            SizedBox(height: 20),

                            // セカンダリボタン
                            Row(
                              children: [
                                if (FeatureFlags.enableTestLogin)
                                  Expanded(
                                    child:
                                        EmailLoginWidgets.buildSecondaryButton(
                                      text: 'テストログイン',
                                      icon: Icons.bug_report,
                                      onPressed: _testLogin,
                                      colors: [
                                        Color(0xFF38b2ac).withOpacity(0.8),
                                        Color(0xFF319795).withOpacity(0.9),
                                      ],
                                      isLoading: isLoading,
                                    ),
                                  ),
                                if (FeatureFlags.enableTestLogin)
                                  SizedBox(width: 12),
                                Expanded(
                                  child: EmailLoginWidgets.buildSecondaryButton(
                                    text: 'パスワードリセット',
                                    icon: Icons.refresh,
                                    onPressed: _resetPassword,
                                    colors: [
                                      Color(0xFFf093fb).withOpacity(0.8),
                                      Color(0xFFf5576c).withOpacity(0.9),
                                    ],
                                    isLoading: isLoading,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),
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
}

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
