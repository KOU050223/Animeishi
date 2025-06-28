import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/profile_customization_data.dart';

/// プロフィールデータ処理サービス
class ProfileDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ユーザーのカスタマイゼーション設定を読み込む
  static Future<ProfileCustomization?> loadUserCustomization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return ProfileCustomization.fromJson(data);
      }
    } catch (e) {
      print('カスタマイゼーション読み込みエラー: $e');
    }
    return null;
  }

  /// プロフィール情報を保存する
  static Future<bool> saveProfile({
    required String username,
    required String email,
    required List<String> selectedGenres,
    required ProfileCustomization customization,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Firestoreに保存するデータを構築
      final profileData = {
        'username': username,
        'email': email,
        'selectedGenres': selectedGenres,
        'updatedAt': FieldValue.serverTimestamp(),
        ...customization.toJson(),
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(profileData, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('プロフィール保存エラー: $e');
      return false;
    }
  }

  /// カスタマイゼーション設定のみを保存する
  static Future<bool> saveCustomization(ProfileCustomization customization) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(customization.toJson(), SetOptions(merge: true));

      return true;
    } catch (e) {
      print('カスタマイゼーション保存エラー: $e');
      return false;
    }
  }

  /// ユーザーの基本プロフィール情報を取得する
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('プロフィール取得エラー: $e');
    }
    return null;
  }

  /// メールアドレスを更新する（Firebase Auth + Firestore）
  static Future<bool> updateEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Firebase Authのメールアドレスを更新
      await user.updateEmail(newEmail);
      
      // Firestoreのメールアドレスも更新
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'email': newEmail});

      return true;
    } catch (e) {
      print('メールアドレス更新エラー: $e');
      return false;
    }
  }

  /// プロフィールの削除
  static Future<bool> deleteProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .delete();

      return true;
    } catch (e) {
      print('プロフィール削除エラー: $e');
      return false;
    }
  }
} 