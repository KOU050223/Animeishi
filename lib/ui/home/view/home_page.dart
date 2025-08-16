import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';
import 'package:animeishi/ui/camera/view/qr_page.dart';
import 'package:animeishi/ui/sns/view/sns_page.dart';
import 'package:animeishi/ui/profile/services/qr_image_service.dart';
import 'package:animeishi/ui/profile/services/qr_save_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;

  final User? _user = FirebaseAuth.instance.currentUser;
  String get qrData => _user?.uid ?? 'No UID';

  // 各ページのウィジェットリスト（ページを保持してスクロール位置などを維持）
  final List<Widget> _pages = [
    const HomeTabPage(), // QRコードを表示するホームタブ
    const AnimeListPage(),
    const QRScannerPage(), // QRコードスキャン画面
    const SNSPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'フレンド'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
          ],
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}

// ホームタブの内容
class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Uint8List? _qrImageData;
  bool _isGenerating = false;
  User? _currentUser;
  String? _lastUserId; // 最後に処理したユーザーIDを記録

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _lastUserId = _currentUser?.uid;
    if (_currentUser != null) {
      _generateQRCode();
    }
  }

  Future<void> _generateQRCode() async {
    if (_currentUser == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // QRデータをユーザーIDのみに変更
      final qrData = _currentUser!.uid;
      final imageData = await QRImageService.generateQRImage(
        qrData,
        size: 200.0,
        foregroundColor: const Color(0xFF667EEA), // ブランドカラー
        backgroundColor: Colors.white,
      );

      if (mounted) {
        setState(() {
          _qrImageData = imageData;
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QRコード生成に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// QR画像をギャラリーに保存する
  Future<void> _saveQRToGallery() async {
    if (_qrImageData == null || _currentUser == null) return;

    try {
      // ユーザー名を取得（表示名がある場合は表示名、なければメールアドレス）
      final username = _currentUser!.displayName ?? _currentUser!.email ?? 'user';
      final filename = QRSaveService.generateFilename(username);
      final success =
          await QRSaveService.saveToGallery(_qrImageData!, filename);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QRコードを保存しました'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    final String qrData = user?.uid != null 
        ? "https://animeishi-viewer.web.app/user/${user!.uid}"
        : "No UID";

    final String? currentUserId = user?.uid;

    // ユーザーIDが変更された場合のみ処理（無限ループを防ぐ）
    if (currentUserId != _lastUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentUser = user;
          _lastUserId = currentUserId;
          _qrImageData = null; // 既存の画像をクリア
        });

        if (user != null && mounted) {
          _generateQRCode();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('アニ名刺'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'あなたのQRコード',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user != null) ...[
                    if (_isGenerating)
                      const Column(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'QRコード生成中...',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else if (_qrImageData != null)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            _qrImageData!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'QRコードを\n生成できませんでした',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ] else
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'ログインしてください',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // 保存ボタン（QRコードが生成されている場合のみ表示）
                  if (user != null &&
                      _qrImageData != null &&
                      !_isGenerating) ...[
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _saveQRToGallery,
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text('保存'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    user?.email ?? 'ゲスト',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                   
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QRスキャナーページ
class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコードスキャン'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const ScannerWidget(),
    );
  }
}
