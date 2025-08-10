import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/watch/view/watch_anime.dart';

class WatchListPage extends StatefulWidget {
  @override
  _WatchListPageState createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _animeList = [];
  Set<String> _selectedAnime = {};

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

    _fetchSelectedAnime();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _fetchSelectedAnime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selectedAnime')
            .get();

        _selectedAnime = snapshot.docs.map((doc) => doc.id).toSet();
        await _fetchAnimeDetails();
      } catch (e) {
        print('Failed to fetch selected anime: $e');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAnimeDetails() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('titles').get();

      final List<Map<String, dynamic>> fetchedList = snapshot.docs
          .where((doc) => _selectedAnime.contains(doc.id))
          .map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'].toString(),
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      // 年・月順でソート
      fetchedList.sort((a, b) {
        final aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
        final bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
        if (aYear != bYear) return bYear.compareTo(aYear); // 新しい年が先

        final aMonth = int.tryParse(a['firstmonth'].toString()) ?? 0;
        final bMonth = int.tryParse(b['firstmonth'].toString()) ?? 0;
        return bMonth.compareTo(aMonth); // 新しい月が先
      });

      setState(() {
        _animeList = fetchedList;
        _isLoading = false;
      });

      // アニメーション開始
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch anime details: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchSelectedAnime();
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
              ? _buildLoadingState()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      slivers: [
                        // カスタムAppBar
                        _buildCustomAppBar(),

                        // 統計カード
                        _buildStatisticsCard(),

                        // アニメリスト
                        _animeList.isEmpty
                            ? SliverFillRemaining(
                                child: _buildEmptyState(),
                              )
                            : SliverPadding(
                                padding: EdgeInsets.all(20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final anime = _animeList[index];
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: _buildAnimeCard(anime, index),
                                      );
                                    },
                                    childCount: _animeList.length,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            '視聴履歴を読み込み中...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
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
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF667eea),
              size: 20,
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF48BB78),
                      Color(0xFF38A169),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '視聴履歴',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(24),
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
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF48BB78), Color(0xFF38A169)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF48BB78).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '視聴統計',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      Text(
                        'あなたのアニメ視聴記録',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '総視聴数',
                    _animeList.length.toString(),
                    Icons.movie_outlined,
                    Color(0xFF48BB78),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    '最新年度',
                    _getLatestYear(),
                    Icons.calendar_today,
                    Color(0xFF4299E1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  String _getLatestYear() {
    if (_animeList.isEmpty) return '-';

    final years = _animeList
        .map((anime) => int.tryParse(anime['firstyear'].toString()) ?? 0)
        .where((year) => year > 0)
        .toList();

    if (years.isEmpty) return '-';

    years.sort();
    return years.last.toString();
  }

  Widget _buildAnimeCard(Map<String, dynamic> anime, int index) {
    final title = anime['title'] ?? 'タイトル不明';
    final year = anime['firstyear'] ?? '';
    final month = anime['firstmonth'] ?? '';
    final comment = anime['comment'] ?? '';

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchAnimePage(anime: anime),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // アニメアイコン
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF48BB78),
                                Color(0xFF38A169),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF48BB78).withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        SizedBox(width: 16),

                        // アニメ情報
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF48BB78).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 12,
                                          color: Color(0xFF48BB78),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '$year年$month月',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF48BB78),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (comment.isNotEmpty) ...[
                                SizedBox(height: 8),
                                Text(
                                  comment,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF718096),
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // 矢印アイコン
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFF48BB78).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF48BB78),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF48BB78).withOpacity(0.2),
                  Color(0xFF38A169).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.history,
              size: 60,
              color: Color(0xFF48BB78).withOpacity(0.6),
            ),
          ),
          SizedBox(height: 32),
          Text(
            '視聴履歴がありません',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'アニメを登録すると\nここに視聴履歴が表示されます',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF718096),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF48BB78), Color(0xFF38A169)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF48BB78).withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              '📱 アニメを探しに行く',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
