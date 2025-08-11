import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import '../controllers/scan_result_animation_controller.dart';
import '../services/scan_data_service.dart';
import '../components/scan_result_widgets.dart';
import '../components/scan_result_painters.dart';

class ScanDataWidget extends StatefulWidget {
  final BarcodeCapture? scandata;
  const ScanDataWidget({Key? key, this.scandata}) : super(key: key);

  @override
  State<ScanDataWidget> createState() => _ScanDataWidgetState();
}

class _ScanDataWidgetState extends State<ScanDataWidget>
    with TickerProviderStateMixin {
  late ScanResultAnimationController _animationController;
  ScanDataResult? _scanResult;
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  /// 初期化とデータ取得
  void _initializeAndFetch() async {
    // アニメーション初期化
    _animationController = ScanResultAnimationController();
    _animationController.initialize(this);
    _animationController.startAnimations();

    // QRコードからユーザーID抽出
    _userId = ScanDataService.extractUserIdFromQR(
      widget.scandata?.barcodes.first.rawValue,
    );

    print('QR取得後の$_userId');

    if (_userId == null) {
      setState(() {
        _scanResult = ScanDataResult(
          success: false,
          errorType: ScanDataErrorType.invalidQR,
        );
        _isLoading = false;
      });
      return;
    }

    // データ取得
    try {
      final result = await ScanDataService.fetchUserData(_userId!);
      setState(() {
        _scanResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _scanResult = ScanDataResult(
          success: false,
          errorType: ScanDataErrorType.networkError,
          errorMessage: e.toString(),
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            ScanResultParticleBackground(
              animationController: _animationController.particleController,
            ),

            // メインコンテンツ
            SafeArea(
              child: AnimatedScanResultContainer(
                animationController: _animationController,
                child: _buildContent(),
              ),
            ),

            // 戻るボタン
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF667EEA),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// コンテンツ構築
  Widget _buildContent() {
    if (_isLoading) {
      return ScanResultWidgets.buildLoadingState();
    }

    if (_scanResult == null || !_scanResult!.success) {
      return SlideAnimatedContainer(
        animationController: _animationController,
        child: ScanResultWidgets.buildErrorState(
          _scanResult?.errorType ?? ScanDataErrorType.networkError,
          message: _scanResult?.errorMessage,
        ),
      );
    }

    return _buildSuccessContent();
  }

  /// 成功時のコンテンツ構築
  Widget _buildSuccessContent() {
    final userData = _scanResult!.userData!;
    final animeList = _scanResult!.animeList!;
    final userProfile = ScanDataService.parseUserProfile(userData);

    return SlideAnimatedContainer(
      animationController: _animationController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // お祝いアニメーション
            CelebrationAnimatedWidget(
              animationController: _animationController,
              child: ScanResultWidgets.buildSuccessHeader(),
            ),

            // ユーザー情報カード
            ScanResultWidgets.buildUserInfoCard(userProfile),

            const SizedBox(height: 20),

            // アニメリストカード
            ScanResultWidgets.buildAnimeListCard(animeList),
          ],
        ),
      ),
    );
  }
}
