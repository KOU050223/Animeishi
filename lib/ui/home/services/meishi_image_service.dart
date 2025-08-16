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
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
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

      // 画像データを取得
      final Uint8List imageData = await imageFile.readAsBytes();
      print('画像データサイズ: ${imageData.length} bytes');

      // 画像データが有効かチェック
      if (imageData.isEmpty) {
        print('画像データが空です');
        return null;
      }

      // メタデータを詳細に設定
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadTime': DateTime.now().toIso8601String(),
          'originalName': imageFile.name,
        },
      );

      final UploadTask uploadTask = ref.putData(imageData, metadata);

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
    if (user == null) {
      print('getMeishiImageURL: ユーザーがログインしていません');
      return null;
    }

    try {
      print('getMeishiImageURL: ユーザーID ${user.uid} の名刺画像URLを取得中...');
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imageURL = data['meishiImageURL'] as String?;
        print('getMeishiImageURL: 取得結果 = $imageURL');
        return imageURL;
      } else {
        print('getMeishiImageURL: ユーザードキュメントが存在しません');
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
