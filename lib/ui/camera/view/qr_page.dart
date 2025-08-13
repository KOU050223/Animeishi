import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/camera/view/scandata.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/utils/error_handler.dart';
import 'package:animeishi/utils/validators.dart';
import 'package:animeishi/ui/camera/services/anime_analysis_service.dart';
import 'package:animeishi/ui/camera/services/scan_data_service.dart';
import 'dart:math' as math;

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with TickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _fadeController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  bool _isScanning = true;
  DateTime? _lastScanTime;

  /// **Firestore にスキャン情報を保存する（検証強化版）**
  Future<void> saveUserIdToFirestore(String scannedData) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError(ErrorHandler.getQRErrorMessage('unauthenticated'));
        return;
      }

      String currentUserId = currentUser.uid;

      // 1. QRコードデータの検証
      final userId = _extractUserIdFromQR(scannedData);
      if (userId == null) {
        _showError(ErrorHandler.getQRErrorMessage('invalid_format'));
        return;
      }

      // 2. ユーザーID形式の検証
      final validationError = Validators.validateUserId(userId);
      if (validationError != null) {
        _showError(validationError);
        return;
      }

      // 3. 自分自身のチェック
      if (currentUser.uid == userId) {
        _showError(ErrorHandler.getQRErrorMessage('self_scan'));
        return;
      }

      // 4. ユーザーの存在確認
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _showError(ErrorHandler.getQRErrorMessage('user_not_found'));
        return;
      }

      // 5. 既にフレンドかチェック
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('meishies')
          .doc(userId)
          .get();

      if (friendDoc.exists) {
        _showError(ErrorHandler.getQRErrorMessage('already_friend'));
        return;
      }

      // 6. フレンド追加処理（双方向）
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('meishies')
          .doc(userId)
          .set({
        'scanned_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meishies')
          .doc(currentUserId)
          .set({
        'scanned_at': FieldValue.serverTimestamp(),
      });

      // --- ここからAI分析処理を追加 ---
      try {
        print('[QR] アニメ傾向分析開始: $userId');
        final animeList = await ScanDataService.getAnimeDetails(
          await ScanDataService.getSelectedAnimeTIDs(userId),
        );
        final userData = await ScanDataService.getUserData(userId);
        final username = userData?['username'] ?? null;

        final analysisService = AnimeAnalysisService();
        final comment = await analysisService.analyzeAndSaveAnimeTrends(
          animeList: animeList,
          friendUserId: userId,
          username: username,
        );
        print('[QR] AI分析コメント: $comment');
      } catch (e) {
        print('[QR] AI分析エラー: $e');
      }
      // --- ここまで ---

      _showSuccess('フレンドを追加しました');
      ErrorHandler.logInfo('QR Scan', 'Successfully added friend: $userId');
    } catch (e) {
      ErrorHandler.logError('QR scan', e);
      _showError('フレンド追加に失敗しました');
    }
  }

  /// QRコードからユーザーIDを抽出
  String? _extractUserIdFromQR(String qrData) {
    // QRコードのデータ形式に応じて調整
    // 例: "animeishi://user/{userId}" 形式の場合
    final uri = Uri.tryParse(qrData);
    if (uri?.scheme == 'animeishi' && uri?.pathSegments.length == 2) {
      if (uri!.pathSegments[0] == 'user') {
        return uri.pathSegments[1];
      }
    }

    // 直接ユーザーIDの場合
    if (RegExp(r'^[a-zA-Z0-9]{28}$').hasMatch(qrData)) {
      return qrData;
    }

    return null;
  }

  /// エラーメッセージ表示
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 成功メッセージ表示
  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // スキャンライン用のアニメーション
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // パルス用のアニメーション
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // パーティクル用のアニメーション
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();

    // フェード用のアニメーション
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // アニメーション開始
    _animationController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _fadeController.dispose();
    // カメラコントローラーの安全な停止
    try {
      controller.stop();
    } catch (e) {
      print('カメラ停止エラー: $e');
    }
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8D5FF),
              Color(0xFFB8E6FF),
              Color(0xFFFFD6E8),
              Color(0xFFE8FFD6),
            ],
          ),
        ),
        child: Stack(
          children: [
            // パーティクルアニメーション背景
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: QRParticlePainter(_particleController.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),

            // カメラプレビュー（中央のスキャンエリアのみ）
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: MobileScanner(
                    controller: controller,
                    fit: BoxFit.cover,
                    onDetect: _isScanning
                        ? (scandata) {
                            // バーコードリストが空でないかチェック
                            if (scandata.barcodes.isEmpty) {
                              print('バーコードが検出されませんでした');
                              return;
                            }

                            // 重複検出を防ぐクールダウン（1秒）
                            final now = DateTime.now();
                            if (_lastScanTime != null &&
                                now.difference(_lastScanTime!).inMilliseconds <
                                    1000) {
                              return;
                            }
                            _lastScanTime = now;

                            final scannedUserId =
                                scandata.barcodes.first.rawValue;
                            print('スキャン結果: $scannedUserId');

                            if (scannedUserId != null &&
                                scannedUserId.isNotEmpty) {
                              setState(() {
                                _isScanning = false;
                                HapticFeedback.mediumImpact(); // バイブレーション
                              });

                              // カメラを安全に停止
                              try {
                                controller.stop();
                              } catch (e) {
                                print('カメラ停止エラー: $e');
                              }

                              saveUserIdToFirestore(scannedUserId);

                              // 少し遅延してから画面遷移
                              Future.delayed(Duration(milliseconds: 500), () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        ScanDataWidget(scandata: scandata),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
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
                              });
                            } else {
                              print('無効なQRコードです: $scannedUserId');
                            }
                          }
                        : null,
                  ),
                ),
              ),
            ),

            // ヘッダー
            _buildModernHeader(context),

            // スキャンエリアのオーバーレイ
            _buildModernScanArea(),

            // 底部のコントロール
            _buildModernBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: MediaQuery.of(context).padding.top + 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // 戻るボタン
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      HomePage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.grey.shade700,
                          size: 22,
                        ),
                      ),
                    ),
                  ),

                  // タイトル部分
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'QRコードスキャン',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'アニ名刺を交換しよう',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 48), // バランス調整
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernScanArea() {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: 300,
          height: 300,
          child: Stack(
            children: [
              // スキャンフレーム
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 4つ角のアクセント
                    ...List.generate(4, (index) {
                      return Positioned(
                        top: index < 2 ? -2 : null,
                        bottom: index >= 2 ? -2 : null,
                        left: index % 2 == 0 ? -2 : null,
                        right: index % 2 == 1 ? -2 : null,
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF667EEA),
                                      const Color(0xFF764BA2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: index == 0
                                        ? const Radius.circular(25)
                                        : Radius.zero,
                                    topRight: index == 1
                                        ? const Radius.circular(25)
                                        : Radius.zero,
                                    bottomLeft: index == 2
                                        ? const Radius.circular(25)
                                        : Radius.zero,
                                    bottomRight: index == 3
                                        ? const Radius.circular(25)
                                        : Radius.zero,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF667EEA)
                                          .withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: index < 2
                                          ? const BorderSide(
                                              color: Colors.white, width: 3)
                                          : BorderSide.none,
                                      bottom: index >= 2
                                          ? const BorderSide(
                                              color: Colors.white, width: 3)
                                          : BorderSide.none,
                                      left: index % 2 == 0
                                          ? const BorderSide(
                                              color: Colors.white, width: 3)
                                          : BorderSide.none,
                                      right: index % 2 == 1
                                          ? const BorderSide(
                                              color: Colors.white, width: 3)
                                          : BorderSide.none,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: index == 0
                                          ? const Radius.circular(20)
                                          : Radius.zero,
                                      topRight: index == 1
                                          ? const Radius.circular(20)
                                          : Radius.zero,
                                      bottomLeft: index == 2
                                          ? const Radius.circular(20)
                                          : Radius.zero,
                                      bottomRight: index == 3
                                          ? const Radius.circular(20)
                                          : Radius.zero,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),

                    // スキャンライン
                    AnimatedBuilder(
                      animation: _scanAnimation,
                      builder: (context, child) {
                        return Positioned(
                          top: 300 * _scanAnimation.value - 3,
                          left: 30,
                          right: 30,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF667EEA),
                                  Color(0xFF764BA2),
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF667EEA).withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.center_focus_strong,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'QRコードをフレーム内に合わせてください',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QRParticlePainter extends CustomPainter {
  final double animationValue;

  QRParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);

      final animatedX = x + math.sin(offset) * 10;
      final animatedY = y + math.cos(offset) * 10;

      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 4 * math.pi + i) * 1;

      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.6),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.6),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.6),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.6),
      ][i % 4];

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
