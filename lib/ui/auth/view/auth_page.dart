// 遷移先
import 'package:animeishi/ui/auth/view/email_login_page.dart';
import 'package:animeishi/ui/auth/view/email_sign_up_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';

// 標準
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';

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
  late Timer timer;
  late List<Particle> particles;
  
  // ログアウト状態管理
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    
    // パーティクル初期化
    particles = List<Particle>.generate(50, (index) => Particle());
    
    // パーティクルアニメーション
    const duration = Duration(milliseconds: 1000 ~/ 60);
    timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          for (var element in particles) {
            element.moveParticle();
          }
        });
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
    timer.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    
    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション（適度な色味の美しいグラデーション）
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD6BCFA), // ソフトパープル
                  Color(0xFFBFDBFE), // ソフトブルー
                  Color(0xFFFBCFE8), // ソフトピンク
                  Color(0xFFD1FAE5), // ソフトグリーン
                ],
              ),
            ),
          ),
          
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
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
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
                              // アプリアイコン（モダンで自然なデザインに変更）
                              Container(
                                width: isSmallScreen ? 100 : 120,
                                height: isSmallScreen ? 100 : 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF667eea).withOpacity(0.8),
                                      Color(0xFF764ba2).withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF667eea).withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 背景の装飾
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    // メインアイコン
                                    Icon(
                                      Icons.credit_card,
                                      size: isSmallScreen ? 40 : 48,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 32 : 40),
                              
                              // アプリタイトル（フォントスタイル改善）
                              Text(
                                'アニ名刺',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 40 : 52,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF2D3748), // ダークグレー
                                  letterSpacing: 1.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              
                              // サブタイトル（フォントスタイル改善）
                              Text(
                                'アニメ好きのための名刺交換アプリ',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  color: Color(0xFF718096), // ミディアムグレー
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 60 : 80),
                      
                      // ボタン部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // ログインボタン（淡い色合いに変更）
                            _buildAnimatedButton(
                              text: 'ログイン',
                              icon: Icons.login,
                              gradientColors: [
                                Color(0xFF667eea).withOpacity(0.8),
                                Color(0xFF764ba2).withOpacity(0.9),
                              ],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => EmailLoginPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: 20),
                            
                            // サインアップボタン（淡い色合いに変更）
                            _buildAnimatedButton(
                              text: '新規登録',
                              icon: Icons.person_add,
                              gradientColors: [
                                Color(0xFFf093fb).withOpacity(0.8),
                                Color(0xFFf5576c).withOpacity(0.9),
                              ],
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => EmailSignUpPage(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1.0, 0.0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: isSmallScreen ? 40 : 50),
                            
                            // ログアウトボタン（改善版）
                            StreamBuilder<User?>(
                              stream: FirebaseAuth.instance.authStateChanges(),
                              builder: (context, snapshot) {
                                return _buildLogoutButton();
                              },
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

  Widget _buildAnimatedButton({
    required String text,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    // 現在のログイン状態をチェック
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = currentUser != null;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (_isLoggingOut || !isLoggedIn) ? null : _showLogoutDialog, // ローディング中またはログアウト済みは無効化
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (_isLoggingOut || !isLoggedIn)
                    ? [
                        Colors.grey.withOpacity(0.6),
                        Colors.grey.withOpacity(0.4),
                      ]
                    : [
                        Colors.white.withOpacity(0.9),
                        Colors.white.withOpacity(0.7),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (_isLoggingOut || !isLoggedIn)
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: (_isLoggingOut || !isLoggedIn)
                          ? [
                              Colors.grey.shade400,
                              Colors.grey.shade500,
                            ]
                          : [
                              Colors.red.shade300.withOpacity(0.8),
                              Colors.red.shade400.withOpacity(0.9),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _isLoggingOut
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isLoggedIn ? Icons.logout_rounded : Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
                SizedBox(width: 12),
                Text(
                  _isLoggingOut 
                      ? 'ログアウト中...' 
                      : isLoggedIn 
                          ? 'ログアウト' 
                          : 'ログアウト済み',
                  style: TextStyle(
                    color: (_isLoggingOut || !isLoggedIn)
                        ? Color(0xFF718096)
                        : Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    if (_isLoggingOut) return; // ローディング中は何もしない
    
    showDialog(
      context: context,
      barrierDismissible: !_isLoggingOut, // ローディング中はダイアログを閉じられないように
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ログアウトアイコン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade300,
                        Colors.red.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // タイトル
                Text(
                  'ログアウトしますか？',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                SizedBox(height: 12),
                
                // サブタイトル
                Text(
                  '現在のセッションを終了します',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 32),
                
                // ボタン行
                Row(
                  children: [
                                         // キャンセルボタン
                     Expanded(
                       child: Container(
                         height: 50,
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             colors: _isLoggingOut
                                 ? [
                                     Colors.grey.shade200,
                                     Colors.grey.shade300,
                                   ]
                                 : [
                                     Colors.grey.shade300,
                                     Colors.grey.shade400,
                                   ],
                           ),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.grey.withOpacity(0.3),
                               blurRadius: 8,
                               offset: Offset(0, 3),
                             ),
                           ],
                         ),
                         child: Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(20),
                             onTap: _isLoggingOut ? null : () => Navigator.of(context).pop(),
                             child: Center(
                               child: Text(
                                 'キャンセル',
                                 style: TextStyle(
                                   color: _isLoggingOut 
                                       ? Colors.grey.shade500
                                       : Colors.white,
                                   fontSize: 16,
                                   fontWeight: FontWeight.w600,
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ),
                     ),
                     
                     SizedBox(width: 16),
                     
                     // ログアウトボタン
                     Expanded(
                       child: Container(
                         height: 50,
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             colors: _isLoggingOut
                                 ? [
                                     Colors.grey.shade400,
                                     Colors.grey.shade500,
                                   ]
                                 : [
                                     Colors.red.shade400,
                                     Colors.red.shade600,
                                   ],
                           ),
                           borderRadius: BorderRadius.circular(20),
                           boxShadow: [
                             BoxShadow(
                               color: _isLoggingOut 
                                   ? Colors.grey.withOpacity(0.3)
                                   : Colors.red.withOpacity(0.4),
                               blurRadius: 12,
                               offset: Offset(0, 4),
                             ),
                           ],
                         ),
                         child: Material(
                           color: Colors.transparent,
                           child: InkWell(
                             borderRadius: BorderRadius.circular(20),
                             onTap: _isLoggingOut ? null : _performLogout,
                             child: Center(
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   if (_isLoggingOut) ...[
                                     SizedBox(
                                       width: 16,
                                       height: 16,
                                       child: CircularProgressIndicator(
                                         strokeWidth: 2,
                                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                       ),
                                     ),
                                     SizedBox(width: 8),
                                   ],
                                   Text(
                                     _isLoggingOut ? 'ログアウト中...' : 'ログアウト',
                                     style: TextStyle(
                                       color: Colors.white,
                                       fontSize: 16,
                                       fontWeight: FontWeight.w600,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         ),
                       ),
                     ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _performLogout() async {
    if (_isLoggingOut) return; // 既にログアウト中の場合は何もしない
    
    setState(() {
      _isLoggingOut = true;
    });
    
    try {
      // 現在のログイン状態をチェック
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        // 既にログアウトしている場合
        if (mounted) {
          setState(() {
            _isLoggingOut = false;
          });
          
          Navigator.of(context).pop(); // ダイアログを閉じる
          
          // 既にログアウト済みのメッセージを表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '既にログアウトしています',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF3182CE),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: EdgeInsets.all(16),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // 少し遅延を入れてローディング状態を見せる
      await Future.delayed(Duration(milliseconds: 500));
      
      await FirebaseAuth.instance.signOut();
      
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        
        Navigator.of(context).pop(); // ダイアログを閉じる
        
        // 成功メッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'ログアウトしました',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF48BB78),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
        
        Navigator.of(context).pop(); // ダイアログを閉じる
        
        // エラーメッセージを表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('ログアウトに失敗しました'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.all(16),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// パーティクルアニメーション用のクラス
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
    if (nextPos.dx < 0 || nextPos.dx > 1000 || nextPos.dy < 0 || nextPos.dy > 800) {
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
