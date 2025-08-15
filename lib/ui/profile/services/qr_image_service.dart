import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QRコード画像生成サービス
/// 任意の文字列からQRコードの画像データを生成する
class QRImageService {
  /// 任意の文字列からQR画像（PNG形式）を生成
  ///
  /// [data] - QRコードに埋め込む文字列
  /// [size] - 画像のサイズ（デフォルト: 512px）
  /// [foregroundColor] - QRコードの色（デフォルト: 黒）
  /// [backgroundColor] - 背景色（デフォルト: 白）
  ///
  /// Returns: PNG形式の画像データ（Uint8List）
  static Future<Uint8List> generateQRImage(
    String data, {
    double size = 512.0,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) async {
    try {
      // QRコードペインターを作成
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
      );

      // Canvasに描画して画像を生成
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

      // 背景を描画
      final backgroundPaint = Paint()..color = backgroundColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, size, size), backgroundPaint);

      // QRコードを中央に配置して描画（パディング16px）
      final qrSize = size - 32; // パディング分を引く
      canvas.save();
      canvas.translate(16, 16); // パディング分移動
      qrPainter.paint(canvas, Size(qrSize, qrSize));
      canvas.restore();

      // Pictureから画像を生成
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.toInt(), size.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('画像データの変換に失敗しました');
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('QR画像の生成に失敗しました: $e');
    }
  }

  /// ユーザーID用のQRデータを生成
  ///
  /// [userId] - Firebase AuthのユーザーID
  ///
  /// Returns: アニ名刺用のQRデータ文字列
  static String generateAnimeishiQRData(String userId) {
    return 'animeishi://user/$userId';
  }

  /// ユーザーID用のQR画像を生成（便利メソッド）
  ///
  /// [userId] - Firebase AuthのユーザーID
  /// [size] - 画像のサイズ（デフォルト: 512px）
  /// [foregroundColor] - QRコードの色（デフォルト: 黒）
  /// [backgroundColor] - 背景色（デフォルト: 白）
  ///
  /// Returns: PNG形式の画像データ（Uint8List）
  static Future<Uint8List> generateUserQRImage(
    String userId, {
    double size = 512.0,
    Color foregroundColor = Colors.black,
    Color backgroundColor = Colors.white,
  }) async {
    final qrData = generateAnimeishiQRData(userId);
    return generateQRImage(
      qrData,
      size: size,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }

  /// QRデータの形式をバリデート
  ///
  /// [data] - バリデートするQRデータ
  ///
  /// Returns: バリデーションエラーメッセージ（正常な場合はnull）
  static String? validateQRData(String? data) {
    if (data == null || data.isEmpty) {
      return 'QRコードデータが空です';
    }

    if (data.length > 2953) {
      return 'QRコードデータが長すぎます（最大2953文字）';
    }

    return null;
  }
}
