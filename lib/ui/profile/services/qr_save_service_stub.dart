import 'dart:typed_data';

/// モバイル環境用のスタブファイル（Web機能は使用不可）
class QRSaveServiceWeb {
  static Future<bool> downloadImage(
      Uint8List imageData, String filename) async {
    throw Exception('Web専用機能はモバイル環境では利用できません');
  }
}
