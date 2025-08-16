import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_header.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_loading.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_empty.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_friends_list.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_delete_dialog.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_snackbar.dart';
import 'package:animeishi/ui/sns/view/widgets/sns_particle_painter.dart';
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
    if (user != null && mounted) {
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

      if (mounted) {
        setState(() {
          _friendIds = friendIds;
          _friendNames = friendNames;
          _friendGenres = friendGenres;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to fetch friends: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

      if (mounted) {
        setState(() {
          final index = _friendIds.indexOf(friendId);
          _friendIds.removeAt(index);
          _friendNames.removeAt(index);
          _friendGenres.removeAt(index);
        });
      }

      _showSnackBar('フレンドを削除しました', isSuccess: true);
    } catch (e) {
      print('Failed to delete friend: $e');
      _showSnackBar('削除に失敗しました', isSuccess: false);
    }
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(message: message, isSuccess: isSuccess),
    );
  }

  void _showDeleteConfirmationDialog(String friendId, String friendName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteFriendDialog(
        friendName: friendName,
        onDelete: () {
          Navigator.pop(context);
          _deleteFriend(friendId);
        },
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
                    ModernHeader(
                      friendCount: _friendIds.length,
                      onBack: () {
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
                    ),

                    // メインコンテンツ
                    Expanded(
                      child: _isLoading
                          ? LoadingState(slideAnimation: _slideAnimation)
                          : _friendIds.isEmpty
                              ? EmptyState(slideAnimation: _slideAnimation)
                              : FriendsList(
                                  friendIds: _friendIds,
                                  friendNames: _friendNames,
                                  friendGenres: _friendGenres,
                                  slideAnimation: _slideAnimation,
                                  onDelete: _showDeleteConfirmationDialog,
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
