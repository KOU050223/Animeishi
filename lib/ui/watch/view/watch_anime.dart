import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Watch関連のインポート
import '../controllers/watch_anime_animation_controller.dart';
import '../services/favorite_service.dart';
import '../components/anime_detail_painters.dart';
import '../components/anime_detail_widgets.dart';

class WatchAnimePage extends StatefulWidget {
  final Map<String, dynamic> anime;

  WatchAnimePage({required this.anime});

  @override
  _WatchAnimePageState createState() => _WatchAnimePageState();
}

class _WatchAnimePageState extends State<WatchAnimePage>
    with TickerProviderStateMixin {
  // アニメーションコントローラー
  late WatchAnimeAnimationController _animationController;

  // 状態管理
  bool _isFavorite = false;
  bool _isLoading = false;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _animationController = WatchAnimeAnimationController();
    _animationController.initialize(this);
    _animationController.startAnimations();
  }

  Future<void> _loadInitialData() async {
    final tid = widget.anime['tid']?.toString();
    if (tid != null) {
      final isFavorite = await FavoriteService.checkFavoriteStatus(tid);
      setState(() {
        _isFavorite = isFavorite;
      });
    }
  }

  Future<void> _handleFavoriteToggle() async {
    if (_user == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FavoriteService.toggleFavorite(
        widget.anime,
        _isFavorite,
      );

      if (result.success) {
        setState(() {
          _isFavorite = result.isFavorite;
        });

        // アニメーション実行
        _animationController.playFavoriteAnimation();
      }

      // 結果を表示
      FavoriteService.showFavoriteSnackBar(context, result);
    } catch (e) {
      FavoriteService.showFavoriteSnackBar(
        context,
        FavoriteResult(
          success: false,
          message: 'エラーが発生しました',
        ),
      );
    } finally {
      setState(() {
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
        child: Stack(
          children: [
            // パーティクル背景
            ParticleBackgroundWidget(
              animationController: _animationController.particleController,
            ),

            // メインコンテンツ
            SafeArea(
              child: AnimatedWatchAnimeContainer(
                animationController: _animationController,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildAppBar(),
                        SizedBox(height: 24),
                        _buildHeroCard(),
                        SizedBox(height: 24),
                        _buildDetailsCard(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF667eea),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'アニメ詳細',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 48), // バランス調整用
      ],
    );
  }

  Widget _buildHeroCard() {
    return AnimeDetailWidgets.buildHeroCard(
      anime: widget.anime,
      isFavorite: _isFavorite,
      isLoading: _isLoading,
      onFavoritePressed: _handleFavoriteToggle,
      favoriteAnimationWidget: _buildFavoriteAnimationWidget(),
    );
  }

  Widget _buildDetailsCard() {
    return AnimeDetailWidgets.buildDetailsCard(
      anime: widget.anime,
    );
  }

  Widget _buildFavoriteAnimationWidget() {
    return AnimatedBuilder(
      animation: _animationController.favoriteAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animationController.favoriteAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.pink[400]!,
                  Colors.pink[600]!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite,
              color: Colors.white,
              size: 16,
            ),
          ),
        );
      },
    );
  }
}
