import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;

import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';
import 'package:animeishi/ui/camera/view/qr_page.dart';
import 'package:animeishi/ui/SNS/view/SNS_page.dart';
import 'package:animeishi/ui/animes/view/favorites_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // 統計データ
  int _watchedCount = 0;
  int _favoriteCount = 0;
  int _friendCount = 0;
  bool _isLoading = true;

  final User? _user = FirebaseAuth.instance.currentUser;
  String get qrData => _user?.uid ?? "No UID";

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
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    
    // 実際のデータを取得
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    if (_user == null) return;
    
    try {
      // 視聴済みアニメ数を取得
      final selectedAnimeSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('selectedAnime')
          .get();
      
      // お気に入りアニメ数を取得
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('favorites')
          .get();
      
      // フレンド数を取得
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('meishies')
          .get();
      
      setState(() {
        _watchedCount = selectedAnimeSnapshot.docs.length;
        _favoriteCount = favoritesSnapshot.docs.length;
        _friendCount = friendsSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
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
      body: _currentIndex == 0
          ? HomePageContent(
              qrData: qrData, 
              user: _user,
              fadeAnimation: _fadeAnimation,
              slideAnimation: _slideAnimation,
              pulseAnimation: _pulseAnimation,
              watchedCount: _watchedCount,
              favoriteCount: _favoriteCount,
              friendCount: _friendCount,
              isLoading: _isLoading,
              onRefresh: _loadUserStats,
            )
          : PageView(
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
              color: Colors.black.withOpacity(0.1),
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
            BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
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
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アニ名刺'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const HomePageContent(),
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

class HomePageContent extends StatelessWidget {
  final String qrData;
  final User? user;
  final Animation<double> fadeAnimation;
  final Animation<double> slideAnimation;
  final Animation<double> pulseAnimation;
  final int watchedCount;
  final int favoriteCount;
  final int friendCount;
  final bool isLoading;
  final VoidCallback onRefresh;

  const HomePageContent({
    Key? key, 
    required this.qrData, 
    required this.user,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.pulseAnimation,
    required this.watchedCount,
    required this.favoriteCount,
    required this.friendCount,
    required this.isLoading,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E8),
            Color(0xFFF0F8FF),
            Color(0xFFFFF8DC),
            Color(0xFFFFE4E1),
          ],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(8),
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => AuthPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                      color: Color(0xFF667eea),
                      size: 20,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedBuilder(
                  animation: fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, slideAnimation.value),
                      child: Opacity(
                        opacity: fadeAnimation.value,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Color(0xFF667eea),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'おかえりなさい！',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      user?.displayName ?? 'アニメファン',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 統計カード
                  AnimatedBuilder(
                    animation: fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, slideAnimation.value * 1.5),
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: _buildStatsCards(context),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  
                  // QRコードカード
                  AnimatedBuilder(
                    animation: fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, slideAnimation.value * 2),
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: _buildQRCard(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  
                  // クイックアクション
                  AnimatedBuilder(
                    animation: fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, slideAnimation.value * 2.5),
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: _buildQuickActions(context),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  
                  // 最近の活動
                  AnimatedBuilder(
                    animation: fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, slideAnimation.value * 3),
                        child: Opacity(
                          opacity: fadeAnimation.value,
                          child: _buildRecentActivity(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 100), // Bottom navigation bar のためのスペース
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.tv,
            title: '視聴済み',
            value: isLoading ? '...' : watchedCount.toString(),
            subtitle: 'アニメ',
            color: Color(0xFF667eea),
            isLoading: isLoading,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AnimeListPage()),
              );
            },
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.favorite,
            title: 'お気に入り',
            value: isLoading ? '...' : favoriteCount.toString(),
            subtitle: '作品',
            color: Color(0xFFf093fb),
            isLoading: isLoading,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FavoritesPage()),
              );
            },
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people,
            title: 'フレンド',
            value: isLoading ? '...' : friendCount.toString(),
            subtitle: '人',
            color: Color(0xFF4facfe),
            isLoading: isLoading,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SNSPage()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 8),
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
            if (onTap != null)
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: color.withOpacity(0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard() {
    return Container(
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${user?.displayName ?? 'あなた'}の名刺QRコード',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 180.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Text(
            'このQRコードをスキャンして\nあなたの情報を共有しよう！',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックアクション',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnimeListPage()),
                  );
                },
                child: _buildActionCard(
                  icon: Icons.search,
                  title: 'アニメを探す',
                  subtitle: '新しい作品を発見',
                  color: Color(0xFF38b2ac),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScannerWidget()),
                  );
                },
                child: _buildActionCard(
                  icon: Icons.qr_code_scanner,
                  title: 'QRスキャン',
                  subtitle: 'フレンドを追加',
                  color: Color(0xFFed8936),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近の活動',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 15),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
                  ),
                )
              : Column(
                  children: [
                    _buildActivityItem(
                      icon: Icons.tv,
                      title: '視聴履歴',
                      subtitle: '${watchedCount}件のアニメを視聴中',
                      color: Color(0xFF667eea),
                    ),
                    Divider(height: 20, color: Colors.grey[200]),
                    _buildActivityItem(
                      icon: Icons.favorite,
                      title: 'お気に入り',
                      subtitle: '${favoriteCount}件の作品をお気に入り登録',
                      color: Color(0xFFf093fb),
                    ),
                    Divider(height: 20, color: Colors.grey[200]),
                    _buildActivityItem(
                      icon: Icons.people,
                      title: 'フレンド',
                      subtitle: '${friendCount}人とつながっています',
                      color: Color(0xFF4facfe),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}