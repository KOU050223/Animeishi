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

  /// 名刺画像を削除（FirestoreとFirebase Storage両方から）
  static Future<bool> deleteMeishiImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      // 1. 現在の名刺画像URLを取得
      final currentImageURL = await getMeishiImageURL();

      if (currentImageURL != null) {
        // 2. Firebase StorageのURLからパスを抽出して画像を削除
        final storagePath = _extractStoragePathFromURL(currentImageURL);
        if (storagePath != null) {
          try {
            final ref = _storage.ref().child(storagePath);
            await ref.delete();
            print('Firebase Storage画像削除成功: $storagePath');
          } catch (e) {
            print('Firebase Storage画像削除エラー: $e');
            // Storage削除に失敗してもFirestore削除は続行
          }
        }
      } else {
        print('名刺画像URLが取得できませんでした。削除はスキップします。');
        return true; // URLがない場合は削除不要とする
      }

      // 3. Firestoreから名刺画像URLを削除
      await _firestore.collection('users').doc(user.uid).update({
        'meishiImageURL': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('名刺画像削除完了');
      return true;
    } catch (e) {
      print('名刺画像削除エラー: $e');
      return false;
    }
  }

  /// Firebase Storage URLからパスを抽出
  static String? _extractStoragePathFromURL(String imageURL) {
    try {
      final uri = Uri.parse(imageURL);
      final pathSegments = uri.pathSegments;

      // "/v0/b/bucket-name/o/" の後のパスを取得
      String storagePath = '';
      bool foundO = false;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'o' && i + 1 < pathSegments.length) {
          foundO = true;
          continue;
        }
        if (foundO) {
          storagePath = pathSegments.sublist(i).join('/');
          break;
        }
      }

      if (storagePath.isNotEmpty) {
        final decodedPath = Uri.decodeComponent(storagePath);
        print('抽出されたStorage パス: $decodedPath');
        return decodedPath;
      }
    } catch (e) {
      print('Storage パス抽出エラー: $e');
    }
    return null;
  }

  /// 名刺画像を更新（古い画像削除→新しい画像アップロード）
  static Future<String?> updateMeishiImage(XFile imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // 1. 現在の名刺画像URLを取得（削除用）
      final oldImageURL = await getMeishiImageURL();

      // 2. 新しい画像をFirebase Storageにアップロード
      final String? newDownloadURL = await uploadMeishiImage(imageFile);
      if (newDownloadURL == null) {
        print('新しい画像のアップロードに失敗しました');
        return null;
      }

      // 3. Firestoreに新しいURLを保存
      final bool saved = await saveMeishiImageURL(newDownloadURL);
      if (!saved) {
        print('新しい画像URLの保存に失敗しました');
        // 新しくアップロードした画像を削除（ロールバック）
        try {
          final storagePath = _extractStoragePathFromURL(newDownloadURL);
          if (storagePath != null) {
            await _storage.ref().child(storagePath).delete();
          }
        } catch (e) {
          print('ロールバック時の画像削除エラー: $e');
        }
        return null;
      }

      // 4. 古い画像をFirebase Storageから削除（新しい画像が正常に保存された後）
      if (oldImageURL != null) {
        final oldStoragePath = _extractStoragePathFromURL(oldImageURL);
        if (oldStoragePath != null) {
          try {
            await _storage.ref().child(oldStoragePath).delete();
            print('古い画像削除成功: $oldStoragePath');
          } catch (e) {
            print('古い画像削除エラー（新しい画像は正常に設定済み）: $e');
            // 古い画像の削除に失敗しても新しい画像は設定済みなので処理続行
          }
        }
      }

      print('名刺画像更新完了');
      return newDownloadURL;
    } catch (e) {
      print('名刺画像更新エラー: $e');
      return null;
    }
  }

  /// 画像選択から保存までの完全なフロー
  static Future<String?> selectAndUploadMeishiImage() async {
    // 1. 画像を選択
    final XFile? imageFile = await pickImage();
    if (imageFile == null) return null;

    // 2. 名刺画像を更新
    return await updateMeishiImage(imageFile);
  }
}
