import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Web環境専用のQR画像保存サービス
class QRSaveServiceWeb {
  /// Web環境でQR画像をダウンロードとして保存する
  ///
  /// [imageData] - PNG形式の画像データ
  /// [filename] - 保存するファイル名（拡張子なし）
  ///
  /// Returns: 保存が成功した場合はtrue、失敗した場合はfalse
  static Future<bool> downloadImage(
      Uint8List imageData, String filename) async {
    try {
      if (!kIsWeb) {
        throw Exception('この機能はWeb環境専用です');
      }

      // Base64エンコードしてBlobとして作成
      final blob = html.Blob([imageData], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // 一時的なダウンロードリンクを作成
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$filename.png')
        ..style.display = 'none';

      // DOM に追加してクリック、その後削除
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);

      // リソースをクリーンアップ
      html.Url.revokeObjectUrl(url);

      return true;
    } catch (e) {
      print('Web画像ダウンロードエラー: $e');
      return false;
    }
  }
}
