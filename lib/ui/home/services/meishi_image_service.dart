import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// 名刺画像管理サービス
class MeishiImageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 画像を選択する
  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      return await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
    } catch (e) {
      print('画像選択エラー: $e');
      return null;
    }
  }

  /// Firebase Storageに画像をアップロードしてURLを取得
  static Future<String?> uploadMeishiImage(XFile imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final String fileName =
          'meishi_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('meishi_images').child(fileName);

      // 常にバイトデータを使用してWeb/モバイル両方に対応
      final Uint8List imageData = await imageFile.readAsBytes();
      final UploadTask uploadTask =
          ref.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadURL = await snapshot.ref.getDownloadURL();
      print('画像アップロード成功: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('画像アップロードエラー: $e');
      return null;
    }
  }

  /// Firestoreのユーザードキュメントに名刺画像URLを保存
  static Future<bool> saveMeishiImageURL(String imageURL) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'meishiImageURL': imageURL,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('名刺画像URL保存エラー: $e');
      return false;
    }
  }

  /// ユーザーの名刺画像URLを取得
  static Future<String?> getMeishiImageURL() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['meishiImageURL'] as String?;
      }
    } catch (e) {
      print('名刺画像URL取得エラー: $e');
    }
    return null;
  }

  /// 名刺画像を削除
  static Future<bool> deleteMeishiImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // Firestoreから名刺画像URLを削除
      await _firestore.collection('users').doc(user.uid).update({
        'meishiImageURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('名刺画像削除エラー: $e');
      return false;
    }
  }

  /// 画像選択から保存までの完全なフロー
  static Future<String?> selectAndUploadMeishiImage() async {
    // 1. 画像を選択
    final XFile? imageFile = await pickImage();
    if (imageFile == null) return null;

    // 2. Firebase Storageにアップロード
    final String? downloadURL = await uploadMeishiImage(imageFile);
    if (downloadURL == null) return null;

    // 3. FirestoreにURLを保存
    final bool saved = await saveMeishiImageURL(downloadURL);
    if (!saved) return null;

    return downloadURL;
  }
}
