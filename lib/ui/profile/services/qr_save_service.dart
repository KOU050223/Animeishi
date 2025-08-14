import 'package:flutter/foundation.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'qr_save_service_web.dart'
    if (dart.library.io) 'qr_save_service_stub.dart';

/// QR画像の保存サービス
class QRSaveService {
  /// QR画像をデバイスのギャラリーに保存する
  ///
  /// [imageData] - PNG形式の画像データ
  /// [filename] - 保存するファイル名（拡張子なし）
  ///
  /// Returns: 保存が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> saveToGallery(
    Uint8List imageData,
    String filename,
  ) async {
    try {
      // Web環境ではダウンロード機能を使用
      if (kIsWeb) {
        final success =
            await QRSaveServiceWeb.downloadImage(imageData, filename);
        return success;
      }

      // Android 13 (API 33) 以降では MANAGE_EXTERNAL_STORAGE 権限は不要
      // iOS では Photos への書き込み権限が必要
      if (defaultTargetPlatform == TargetPlatform.android) {
        final permission = await Permission.storage.request();
        if (permission == PermissionStatus.permanentlyDenied) {
          throw Exception('ストレージへのアクセス権限が拒否されています。設定から権限を有効にしてください。');
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final permission = await Permission.photos.request();
        if (permission == PermissionStatus.permanentlyDenied) {
          throw Exception('写真への保存権限が拒否されています。設定から権限を有効にしてください。');
        }
      }

      // ギャラリーに保存
      final result = await ImageGallerySaver.saveImage(
        imageData,
        quality: 100,
        name: '${filename}_${DateTime.now().millisecondsSinceEpoch}',
      );

      return result['isSuccess'] == true;
    } catch (e) {
      print('画像保存エラー: $e');
      rethrow;
    }
  }

  /// 権限状況をチェックする
  ///
  /// Returns: 権限の状態と説明
  static Future<Map<String, dynamic>> checkPermissions() async {
    try {
      if (kIsWeb) {
        return {
          'canSave': true,
          'message': 'Web環境では画像をダウンロードとして保存できます。',
        };
      }

      bool canSave = false;
      String message = '';

      if (defaultTargetPlatform == TargetPlatform.android) {
        final storageStatus = await Permission.storage.status;
        canSave = storageStatus == PermissionStatus.granted ||
            storageStatus == PermissionStatus.limited;

        if (!canSave) {
          message = 'ストレージへのアクセス権限が必要です';
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final photosStatus = await Permission.photos.status;
        canSave = photosStatus == PermissionStatus.granted ||
            photosStatus == PermissionStatus.limited;

        if (!canSave) {
          message = '写真への保存権限が必要です';
        }
      } else {
        // その他のプラットフォーム（Windows、macOS、Linuxなど）
        canSave = true;
      }

      return {
        'canSave': canSave,
        'message': message,
      };
    } catch (e) {
      return {
        'canSave': false,
        'message': '権限の確認中にエラーが発生しました',
      };
    }
  }

  /// QR画像の保存用ファイル名を生成する
  ///
  /// [username] - ユーザー名（表示名またはメールアドレス）
  ///
  /// Returns: 保存用のファイル名
  static String generateFilename(String username) {
    // ファイル名に使用できない文字を除去・置換
    final sanitizedUsername = username
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '') // 無効な文字を削除
        .replaceAll('@', '_at_') // @を_at_に置換
        .replaceAll('.', '_') // ドットをアンダースコアに置換
        .replaceAll(' ', '_'); // スペースをアンダースコアに置換

    // 長すぎる場合は切り詰める（最大20文字）
    final trimmedUsername = sanitizedUsername.length > 20
        ? sanitizedUsername.substring(0, 20)
        : sanitizedUsername;

    return 'animeishi_QR_$trimmedUsername';
  }
}
