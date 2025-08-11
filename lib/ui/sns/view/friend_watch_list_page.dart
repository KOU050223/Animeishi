import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animeishi/ui/watch/view/watch_anime.dart';
import 'dart:math' as math;
import 'friend_watch_list_widgets.dart';

enum SortOrder { ascending, descending }

class FriendWatchListPage extends StatefulWidget {
  final String userId;
  final String? userName;

  FriendWatchListPage({required this.userId, this.userName});

  @override
  _FriendWatchListPageState createState() => _FriendWatchListPageState();
}

class _FriendWatchListPageState extends State<FriendWatchListPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Map<String, dynamic>> _animeList = [];
  Set<String> _selectedAnime = {};
  SortOrder _sortOrder = SortOrder.descending;
  String _userName = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName ?? 'フレンド';
    _initAnimations();
    _fetchSelectedAnime();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Future<void> _fetchSelectedAnime() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('selectedAnime')
          .withConverter<String>(
            fromFirestore: (doc, _) => doc.id,
            toFirestore: (id, _) => {},
          )
          .get();
      _selectedAnime = snapshot.docs.map((doc) => doc.data()).toSet();
      await _fetchAnimeDetails();
    } catch (e) {
      print('Failed to fetch selected anime: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAnimeDetails() async {
    try {
      if (_selectedAnime.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final snapshot = await FirebaseFirestore.instance
          .collection('titles')
          .where(FieldPath.documentId, whereIn: _selectedAnime.toList())
          .get();
      _animeList = snapshot.docs.map((doc) => {
            'id': doc.id,
            'tid': doc['TID'].toString(),
            'title': doc['Title'],
            'titleyomi': doc['TitleYomi'],
            'firstmonth': doc['FirstMonth'],
            'firstyear': doc['FirstYear'],
            'comment': doc['Comment'],
          }).toList();
      _sortAnimeList();
    } catch (e) {
      print('Failed to fetch anime details: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortAnimeList() {
    _animeList.sort((a, b) {
      int aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
      int bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
      int aMonth = int.tryParse(a['firstmonth'].toString()) ?? 0;
      int bMonth = int.tryParse(b['firstmonth'].toString()) ?? 0;
      int compare = bYear.compareTo(aYear);
      if (compare == 0) compare = bMonth.compareTo(aMonth);
      return _sortOrder == SortOrder.descending ? compare : -compare;
    });
    setState(() {});
  }

  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.descending
          ? SortOrder.ascending
          : SortOrder.descending;
      _sortAnimeList();
    });
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
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) => CustomPaint(
                painter: FriendParticlePainter(_particleController.value),
                size: MediaQuery.of(context).size,
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    FriendHeader(
                      userName: _userName,
                      animeCount: _animeList.length,
                      sortOrder: _sortOrder,
                      onBack: () => Navigator.of(context).pop(),
                      onSort: _toggleSortOrder,
                    ),
                    Expanded(
                      child: _isLoading
                          ? const FriendLoadingState()
                          : _animeList.isEmpty
                              ? FriendEmptyState(userName: _userName)
                              : FriendAnimeList(
                                  animeList: _animeList,
                                  slideAnimation: _slideAnimation,
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// パーティクルペインターのみ残す
class FriendParticlePainter extends CustomPainter {
  final double animationValue;
  FriendParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);
    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);
      final animatedX = x + math.sin(offset + i) * 12;
      final animatedY = y + math.cos(offset + i) * 12;
      final opacity = (math.sin(animationValue * 3 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 4 * math.pi + i) * 1.5;
      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.6),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.6),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.6),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.6),
        const Color(0xFF667EEA).withOpacity(opacity * 0.4),
      ][i % 5];
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
