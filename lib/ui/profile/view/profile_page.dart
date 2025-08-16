import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:animeishi/ui/profile/view/profile_edit_page.dart'; // ProfileEditPage のインポート
import 'package:animeishi/ui/watch/view/watch_list.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart'; // AuthPage のインポート
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート（ここが重要）
import 'package:animeishi/ui/animes/view/favorites_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  String _username = '';
  String _userId = '';
  String _email = '';
  List<String> _selectedGenres = [];
  int _watchedCount = 0;
  int _favoritesCount = 0;
  int _friendsCount = 0;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _loadUserProfile();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (!mounted) return;

        setState(() {
          _userId = user.uid;
          _email = user.email ?? '';
          _username = user.displayName ?? '';
        });

        // Firestoreからユーザー情報を取得
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return; //非同期処理後に再度チェック

        if (userDoc.exists) {
          // selectedGeneresフィールドが存在しない場合は空のリストを設定
          final data = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _selectedGenres = data != null && data.containsKey('selectedGenres')
                ? List<String>.from(userDoc['selectedGenres'] ?? [])
                : [];
          });
        } else {
          // ユーザードキュメントが存在しない場合は空のリストを設定
          setState(() {
            _selectedGenres = [];
          });
        }

        // 統計データを取得
        await _loadStatistics();

        // アニメーション開始
        _fadeController.forward();
        _slideController.forward();
      } catch (e) {
        print('Failed to load user profile: $e');
        // エラーが発生した場合も空のリストを設定
        setState(() {
          _selectedGenres = [];
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStatistics() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // 視聴済みアニメ数
      final watchedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('selectedAnime')
          .get();

      // お気に入り数
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      // フレンド数
      final friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('meishies')
          .get();

      setState(() {
        _watchedCount = watchedSnapshot.docs.length;
        _favoritesCount = favoritesSnapshot.docs.length;
        _friendsCount = friendsSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading statistics: $e');
    }
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
        child: SafeArea(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        // カスタムAppBar
                        SliverAppBar(
                          expandedHeight: 100,
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          leading: Container(
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage()),
                                  );
                                },
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              'プロフィール',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // プロフィールカード
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.95),
                                  Colors.white.withOpacity(0.85),
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
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  // プロフィール画像
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF667eea),
                                          Color(0xFF764ba2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF667eea)
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // ユーザーネーム
                                  Text(
                                    _username.isEmpty ? '未設定' : _username,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  // メールアドレス
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF667eea).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _email.isEmpty ? '未設定' : _email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF667eea),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 統計セクション
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                    child: _buildStatCard(
                                        '視聴済み',
                                        _watchedCount,
                                        Icons.movie_outlined,
                                        Color(0xFF48BB78))),
                                SizedBox(width: 12),
                                Expanded(
                                    child: _buildStatCard(
                                        'お気に入り',
                                        _favoritesCount,
                                        Icons.favorite,
                                        Color(0xFFED64A6))),
                                SizedBox(width: 12),
                                Expanded(
                                    child: _buildStatCard('フレンド', _friendsCount,
                                        Icons.people, Color(0xFF4299E1))),
                              ],
                            ),
                          ),
                        ),

                        // 好きなジャンル
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.all(20),
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
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFFf093fb),
                                              Color(0xFFf5576c)
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.category,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        '好きなジャンル',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  _selectedGenres.isEmpty
                                      ? Container(
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.grey[600],
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'ジャンルが設定されていません',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: _selectedGenres
                                              .map((genre) => Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFf093fb)
                                                              .withOpacity(0.8),
                                                          Color(0xFFf5576c)
                                                              .withOpacity(0.8),
                                                        ],
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(
                                                                  0xFFf093fb)
                                                              .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      genre,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // アクションボタン
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildActionButton(
                                  '📝 プロフィールを編集',
                                  'ユーザー名やジャンルを変更',
                                  [Color(0xFF667eea), Color(0xFF764ba2)],
                                  () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileEditPage(
                                          username: _username,
                                          selectedGenres: _selectedGenres,
                                          email: _email,
                                        ),
                                      ),
                                    );
                                    if (result != null) {
                                      setState(() {
                                        _username = result['username'];
                                        _selectedGenres =
                                            result['selectedGenres'];
                                        _email = result['email'];
                                      });
                                    }
                                  },
                                ),
                                SizedBox(height: 12),
                                _buildActionButton(
                                  '📺 視聴履歴',
                                  '今まで見たアニメをチェック',
                                  [Color(0xFF48BB78), Color(0xFF38A169)],
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              WatchListPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 12),
                                _buildActionButton(
                                  '💖 お気に入り',
                                  'お気に入りのアニメ一覧',
                                  [Color(0xFFED64A6), Color(0xFFD53F8C)],
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FavoritesPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20),
                                _buildActionButton(
                                  '🔐 ログイン画面',
                                  'アカウント管理',
                                  [Color(0xFF718096), Color(0xFF4A5568)],
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AuthPage()),
                                    );
                                  },
                                ),
                                SizedBox(height: 40),
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
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String title, String subtitle, List<Color> colors, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
