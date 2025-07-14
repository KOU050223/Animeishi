import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/SNS/view/friend_watch_list_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート（ここが重要）
import 'dart:math' as math;

class SNSPage extends StatefulWidget {
  const SNSPage({super.key});

  @override
  State<SNSPage> createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> with TickerProviderStateMixin {
  List<String> _friendIds = [];
  List<String> _friendNames = [];
  List<List<String>> _friendGenres = [];

  String _currentUserId = '';
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _getCurrentUser();
    _fetchFriends();
    
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

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchFriends() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('meishies')
          .get();

      List<String> friendIds = [];
      List<String> friendNames = [];
      List<List<String>> friendGenres = [];

      for (var doc in userDoc.docs) {
        final friendId = doc.id;
        final friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          final friendName = friendDoc['username'] ?? '未設定';
          final genres = List<String>.from(friendDoc['selectedGenres'] ?? []);

          friendIds.add(friendId);
          friendNames.add(friendName);
          friendGenres.add(genres);
        }
      }

      setState(() {
        _friendIds = friendIds;
        _friendNames = friendNames;
        _friendGenres = friendGenres;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFriend(String friendId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('meishies')
          .doc(friendId)
          .delete();

      setState(() {
        final index = _friendIds.indexOf(friendId);
        _friendIds.removeAt(index);
        _friendNames.removeAt(index);
        _friendGenres.removeAt(index);
      });

      _showSuccessMessage('フレンドを削除しました');
    } catch (e) {
      print('Failed to delete friend: $e');
      _showErrorMessage('削除に失敗しました');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String friendId, String friendName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
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
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 警告アイコン
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange[300]!.withOpacity(0.8),
                        Colors.red[300]!.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_remove_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // タイトル
                Text(
                  'フレンドを削除',
                  style: TextStyle(
                    color: const Color(0xFF2D3748),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // フレンド情報カード
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE8D5FF).withOpacity(0.4),
                        const Color(0xFFFFD6E8).withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667EEA).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              friendName,
                              style: TextStyle(
                                color: const Color(0xFF2D3748),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange[600],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'このフレンドを削除すると、視聴履歴の共有や\n名刺の交換ができなくなります。',
                                style: TextStyle(
                                  color: const Color(0xFF4A5568),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // ボタン
                Row(
                  children: [
                    // キャンセルボタン
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey[200]!,
                              Colors.grey[300]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Text(
                                'キャンセル',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // 削除ボタン
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange[400]!,
                              Colors.red[400]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteFriend(friendId);
                            },
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '削除する',
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
        ),
      ),
    );
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
                  painter: SNSParticlePainter(_particleController.value),
                  size: MediaQuery.of(context).size,
                );
              },
            ),
            
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // モダンなヘッダー
                    _buildModernHeader(context),
                    
                    // メインコンテンツ
                    Expanded(
                      child: _isLoading
                          ? _buildLoadingState()
                          : _friendIds.isEmpty
                              ? _buildEmptyState()
                              : _buildFriendsList(),
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

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Row(
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
                          pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
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
                      color: Colors.grey.shade700,
                      size: 22,
                    ),
                  ),
                ),
              ),
              
              // タイトル部分
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'フレンドリスト',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 統計表示
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
                child: Center(
                  child: Text(
                    '${_friendIds.length}',
                    style: TextStyle(
                      color: const Color(0xFF667EEA),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 統計情報カード
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.group,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'あなたのフレンド',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '登録済み ${_friendIds.length}人',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667EEA).withOpacity(0.1),
                        const Color(0xFF764BA2).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '名刺一覧',
                    style: TextStyle(
                      color: Color(0xFF667EEA),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF667EEA)),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'フレンドリストを読み込み中...',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(40),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.1),
                      const Color(0xFF764BA2).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.people_outline,
                  color: Color(0xFF667EEA),
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'まだフレンドがいません',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'QRコードをスキャンして\nフレンドを追加しましょう！',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList() {
    return SlideTransition(
      position: _slideAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _friendIds.length,
        itemBuilder: (context, index) {
          final friendId = _friendIds[index];
          final friendName = _friendNames[index];
          final friendGenres = _friendGenres[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // プロフィールアイコン
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // フレンド情報
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friendName,
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${friendId.length > 20 ? '${friendId.substring(0, 20)}...' : friendId}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // 削除ボタン
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showDeleteConfirmationDialog(friendId, friendName),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // ジャンル表示
                  if (friendGenres.isNotEmpty) ...[
                    Text(
                      '好きなジャンル',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: friendGenres.take(3).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF667EEA).withOpacity(0.1),
                                const Color(0xFF764BA2).withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF667EEA).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                              color: Color(0xFF667EEA),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'ジャンル未設定',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 視聴履歴ボタン
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  FriendWatchListPage(
                                    userId: friendId,
                                    userName: friendName,
                                  ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '視聴履歴を見る',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SNSParticlePainter extends CustomPainter {
  final double animationValue;
  
  SNSParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42);
    
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = (animationValue * 2 * math.pi + i) % (2 * math.pi);
      
      final animatedX = x + math.sin(offset + i * 0.5) * 15;
      final animatedY = y + math.cos(offset + i * 0.3) * 15;
      
      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      final radius = 1 + math.sin(animationValue * 3 * math.pi + i) * 2;
      
      paint.color = [
        const Color(0xFFE8D5FF).withOpacity(opacity * 0.5),
        const Color(0xFFB8E6FF).withOpacity(opacity * 0.5),
        const Color(0xFFFFD6E8).withOpacity(opacity * 0.5),
        const Color(0xFFE8FFD6).withOpacity(opacity * 0.5),
        const Color(0xFF667EEA).withOpacity(opacity * 0.3),
        const Color(0xFF764BA2).withOpacity(opacity * 0.3),
      ][i % 6];
      
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
