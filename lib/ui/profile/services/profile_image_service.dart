import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// プロフィール画像処理サービス
class ProfileImageService {
  static final ImagePicker _picker = ImagePicker();

  /// 画像を選択する
  static Future<ProfileImageResult> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Web用の処理
          final bytes = await image.readAsBytes();
          return ProfileImageResult(
            webImage: bytes,
            success: true,
          );
        } else {
          // モバイル用の処理
          return ProfileImageResult(
            selectedImage: File(image.path),
            success: true,
          );
        }
      } else {
        return ProfileImageResult(
          success: false,
          errorMessage: '画像が選択されませんでした',
        );
      }
    } catch (e) {
      return ProfileImageResult(
        success: false,
        errorMessage: '画像の選択に失敗しました: $e',
      );
    }
  }

  /// 画像をFirebase Storageにアップロードする
  static Future<String?> uploadImage({
    File? imageFile,
    Uint8List? webImage,
  }) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');

      UploadTask uploadTask;
      if (kIsWeb && webImage != null) {
        uploadTask = storageRef.putData(webImage);
      } else if (imageFile != null) {
        uploadTask = storageRef.putFile(imageFile);
      } else {
        return null;
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('画像アップロードエラー: $e');
      return null;
    }
  }

  /// 画像選択のダイアログを表示する
  static void showImageSourceDialog(BuildContext context, Function(ImageSource) onSourceSelected) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'プロフィール画像を選択',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt,
                    label: 'カメラ',
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.camera);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library,
                    label: 'ギャラリー',
                    onTap: () {
                      Navigator.pop(context);
                      onSourceSelected(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Color(0xFF667eea)),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Web環境でのエラーダイアログを表示する
  static void showWebImagePickerDialog(BuildContext context, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Color(0xFF667eea)),
            SizedBox(width: 8),
            Text('画像選択について'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Web環境では画像選択機能に制限があります。'),
            SizedBox(height: 12),
            Text('以下の方法をお試しください：'),
            SizedBox(height: 8),
            Text('• ブラウザを更新してから再度お試しください'),
            Text('• 別のブラウザをご利用ください'),
            Text('• モバイルアプリをご利用ください'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: Text('再試行'),
          ),
        ],
      ),
    );
  }
}

/// 画像選択結果を格納するクラス
class ProfileImageResult {
  final File? selectedImage;
  final Uint8List? webImage;
  final bool success;
  final String? errorMessage;

  ProfileImageResult({
    this.selectedImage,
    this.webImage,
    required this.success,
    this.errorMessage,
  });
} 