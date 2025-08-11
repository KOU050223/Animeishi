import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// お気に入り管理サービス
class FavoriteService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// お気に入り状態を確認する
  static Future<bool> checkFavoriteStatus(String tid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(tid)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// お気に入りに追加する
  static Future<FavoriteResult> addToFavorites(
      Map<String, dynamic> anime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FavoriteResult(
        success: false,
        message: 'ログインが必要です',
      );
    }

    try {
      final tid = anime['tid']?.toString();
      if (tid == null) {
        return FavoriteResult(
          success: false,
          message: 'アニメ情報が不正です',
        );
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(tid)
          .set({
        'title': anime['title'],
        'titleyomi': anime['titleyomi'],
        'tid': anime['tid'],
        'firstyear': anime['firstyear'],
        'firstmonth': anime['firstmonth'],
        'comment': anime['comment'],
        'addedAt': FieldValue.serverTimestamp(),
      });

      return FavoriteResult(
        success: true,
        message: 'お気に入りに追加しました',
        isFavorite: true,
      );
    } catch (e) {
      print('Error adding to favorites: $e');
      return FavoriteResult(
        success: false,
        message: 'お気に入りの追加に失敗しました',
      );
    }
  }

  /// お気に入りから削除する
  static Future<FavoriteResult> removeFromFavorites(String tid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return FavoriteResult(
        success: false,
        message: 'ログインが必要です',
      );
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(tid)
          .delete();

      return FavoriteResult(
        success: true,
        message: 'お気に入りから削除しました',
        isFavorite: false,
      );
    } catch (e) {
      print('Error removing from favorites: $e');
      return FavoriteResult(
        success: false,
        message: 'お気に入りの削除に失敗しました',
      );
    }
  }

  /// お気に入り状態を切り替える
  static Future<FavoriteResult> toggleFavorite(
    Map<String, dynamic> anime,
    bool currentFavoriteStatus,
  ) async {
    final tid = anime['tid']?.toString();
    if (tid == null) {
      return FavoriteResult(
        success: false,
        message: 'アニメ情報が不正です',
      );
    }

    if (currentFavoriteStatus) {
      return await removeFromFavorites(tid);
    } else {
      return await addToFavorites(anime);
    }
  }

  /// ユーザーのお気に入りリストを取得する
  static Future<List<Map<String, dynamic>>> getUserFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      print('Error getting user favorites: $e');
      return [];
    }
  }

  /// お気に入り結果を表示する
  static void showFavoriteSnackBar(
      BuildContext context, FavoriteResult result) {
    Color backgroundColor;
    IconData icon;

    if (result.success) {
      backgroundColor =
          result.isFavorite ? Colors.pink[400]! : Colors.grey[600]!;
      icon = result.isFavorite ? Icons.favorite : Icons.favorite_border;
    } else {
      backgroundColor = Colors.red[400]!;
      icon = Icons.error_outline;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(result.message),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}

/// お気に入り操作の結果を格納するクラス
class FavoriteResult {
  final bool success;
  final String message;
  final bool isFavorite;

  FavoriteResult({
    required this.success,
    required this.message,
    this.isFavorite = false,
  });
}
