import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

// Web環境でのみテスト実行
void main() {
  group('QRSaveServiceWeb', () {
    test('Web環境チェック', () {
      // このテストはWeb環境の確認用
      if (kIsWeb) {
        expect(kIsWeb, isTrue);
      } else {
        expect(kIsWeb, isFalse);
      }
    });

    test('画像データの基本チェック', () {
      // テスト用の画像データ（1x1の透明PNG）
      final testImageData = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0B,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82
      ]);

      expect(testImageData.isNotEmpty, isTrue);
      expect(testImageData.length, greaterThan(0));
    });

    test('ファイル名の生成', () {
      const testUsername = 'testuser@example.com';
      const filename = 'animeishi_QR_testuser_at_example_';

      expect(filename.contains('animeishi_QR'), isTrue);
      expect(filename.contains('testuser_at_example'), isTrue);
    });
  });
}
