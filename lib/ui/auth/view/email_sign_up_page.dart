import 'package:animeishi/ui/auth/view/account_setting_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/auth/components/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';

class EmailSignUpPage extends StatefulWidget {
  const EmailSignUpPage({Key? key}) : super(key: key);

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUpPage> with TickerProviderStateMixin {
  // フォーム関連
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  String errorMessage = '';
  bool isLoading = false;

  // アニメーション関連
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // パーティクルアニメーション用
  late Timer timer;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    
    // パーティクル初期化
    particles = List<Particle>.generate(40, (index) => Particle());
    
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createUserDocument(String userId) async {
    try {
      print('ユーザードキュメント作成開始: $userId');
      
      // まず基本的なユーザードキュメントを作成
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
            'createdAt': FieldValue.serverTimestamp(),
            'email': emailController.text.trim(),
            'uid': userId,
          });
      
      print('基本ユーザードキュメントを作成しました');
      
      // Note: サブコレクション（selectedAnime, meishies, favorites）は
      // 実際にデータが追加されるときに自動的に作成されるため、
      // 初期化時にプレースホルダードキュメントを作成する必要はありません。
      
      print('ユーザードキュメントの作成が完了しました');
    } catch (e) {
      print('ユーザードキュメントの作成中にエラーが発生しました: $e');
      print('エラーの詳細: ${e.runtimeType}');
      rethrow; // エラーを再スローして上位でキャッチできるようにする
    }
  }

  String? _validateEmail() {
    if (emailController.text.isEmpty) {
      return 'メールアドレスを入力してください';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text)) {
      return '正しいメールアドレスを入力してください';
    }
    return null;
  }

  String? _validatePassword() {
    if (passwordController.text.isEmpty) {
      return 'パスワードを入力してください';
    } else if (passwordController.text.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    return null;
  }

  Future<void> _signUp() async {
    final emailError = _validateEmail();
    final passwordError = _validatePassword();
    
    if (emailError != null || passwordError != null) {
      _showStylishValidationDialog(emailError, passwordError);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final User? user = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: emailController.text.trim(), 
                  password: passwordController.text))
          .user;
      
      if (user != null) {
        print("ユーザ登録しました ${user.email} , ${user.uid}");
        await createUserDocument(user.uid);
        
        // 成功フィードバック
        _showSuccessMessage();
        
        // 少し遅延してから画面遷移
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountSettingPage()),
          );
        }
      }
    } catch (e) {
      print('新規登録エラー: $e');
      print('エラータイプ: ${e.runtimeType}');
      
      setState(() {
        errorMessage = _getErrorMessage(e.toString());
      });
      
      // エラーダイアログを表示
      _showErrorDialog(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showStylishValidationDialog(String? emailError, String? passwordError) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // アイコン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade300,
                        Colors.orange.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // タイトル
                Text(
                  '入力内容をご確認ください',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // エラーメッセージリスト
                if (emailError != null || passwordError != null) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (emailError != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Colors.orange.shade600,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  emailError,
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (passwordError != null) SizedBox(height: 12),
                        ],
                        if (passwordError != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: Colors.orange.shade600,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  passwordError,
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                
                SizedBox(height: 24),
                
                // 閉じるボタン
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.orange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          '確認しました',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('アカウントが作成されました！'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
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
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // エラーアイコン
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
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                SizedBox(height: 20),
                
                // タイトル
                Text(
                  '登録エラー',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // エラーメッセージ
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: 24),
                
                // 閉じるボタン
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.shade400,
                        Colors.red.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).pop(),
                      child: Center(
                        child: Text(
                          '確認しました',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'このメールアドレスは既に使用されています';
    } else if (error.contains('weak-password')) {
      return 'パスワードが弱すぎます（6文字以上必要）';
    } else if (error.contains('invalid-email')) {
      return 'メールアドレスの形式が正しくありません';
    }
    return 'エラーが発生しました。もう一度お試しください';
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
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 戻るボタン
                      AuthWidgets.buildBackButton(
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      // タイトル部分
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AuthWidgets.buildPageTitle(
                            title: '新規登録',
                            subtitle: 'アカウントを作成してアニ名刺を始めましょう',
                            icon: Icons.person_add_rounded,
                            iconColors: [
                              Color(0xFFf093fb).withOpacity(0.8),
                              Color(0xFFf5576c).withOpacity(0.9),
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
                            _buildModernTextField(
                              controller: emailController,
                              label: 'メールアドレス',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            
                            SizedBox(height: 20),
                            
                            // パスワード入力
                            _buildModernTextField(
                              controller: passwordController,
                              label: 'パスワード',
                              icon: Icons.lock_outline,
                              obscureText: hidePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  hidePassword ? Icons.visibility_off : Icons.visibility,
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
                            
                            // 登録ボタン
                            _buildSignUpButton(),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Color(0xFF718096),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: TextStyle(
            color: Color(0xFF667eea),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 12, right: 8),
            child: Icon(
              icon,
              color: Color(0xFF718096),
              size: 22,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Color(0xFF667eea).withOpacity(0.8),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFf093fb).withOpacity(0.8),
            Color(0xFFf5576c).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFf093fb).withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : _signUp,
          child: Container(
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '新規登録',
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
  final double radius = _getRandomVal(2, 5);
  
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
      Color(0xFFf093fb).withOpacity(0.06),
      Color(0xFFf5576c).withOpacity(0.08),
      Color(0xFFD6BCFA).withOpacity(0.05),
      Color(0xFFBFDBFE).withOpacity(0.07),
      Colors.white.withOpacity(0.3),
    ];
    final rnd = Random();
    return colorList[rnd.nextInt(colorList.length)];
  }

  static double _getRandomVal(double min, double max) {
    final rnd = Random();
    return rnd.nextDouble() * (max - min) + min;
  }
}
