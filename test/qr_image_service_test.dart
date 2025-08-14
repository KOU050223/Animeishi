import 'package:flutter_test/flutter_test.dart';
import 'package:animeishi/ui/profile/services/qr_image_service.dart';

void main() {
  group('QRImageService', () {
    test('QRデータ生成テスト', () {
      const userId = 'abcdefghijklmnopqrstuvwxyz12';
      final qrData = QRImageService.generateAnimeishiQRData(userId);
      
      expect(qrData, equals('animeishi://user/$userId'));
    });

    test('QRデータバリデーション - 正常なデータ', () {
      const validData = 'animeishi://user/abcdefghijklmnopqrstuvwxyz12';
      final result = QRImageService.validateQRData(validData);
      
      expect(result, isNull);
    });

    test('QRデータバリデーション - 空データ', () {
      final result = QRImageService.validateQRData('');
      
      expect(result, equals('QRコードデータが空です'));
    });

    test('QRデータバリデーション - nullデータ', () {
      final result = QRImageService.validateQRData(null);
      
      expect(result, equals('QRコードデータが空です'));
    });

    test('QRデータバリデーション - 長すぎるデータ', () {
      final longData = 'a' * 3000; // 2953文字を超えるデータ
      final result = QRImageService.validateQRData(longData);
      
      expect(result, equals('QRコードデータが長すぎます（最大2953文字）'));
    });

    test('QR画像生成 - データが短すぎる場合でもエラーにならない', () {
      // 短いデータでも生成は可能であることを確認
      final result = QRImageService.validateQRData('test');
      expect(result, isNull);
    });

    test('QR画像生成 - 日本語データも対応', () {
      const japaneseData = 'こんにちは、世界！';
      final result = QRImageService.validateQRData(japaneseData);
      expect(result, isNull);
    });

    test('ユーザーIDからQRデータを生成', () {
      const userId1 = 'abcdefghijklmnopqrstuvwxyz12';
      const userId2 = '1234567890123456789012345678';
      
      final qrData1 = QRImageService.generateAnimeishiQRData(userId1);
      final qrData2 = QRImageService.generateAnimeishiQRData(userId2);
      
      expect(qrData1, equals('animeishi://user/$userId1'));
      expect(qrData2, equals('animeishi://user/$userId2'));
      expect(qrData1, isNot(equals(qrData2)));
    });
  });
}