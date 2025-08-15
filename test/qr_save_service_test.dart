import 'package:flutter_test/flutter_test.dart';
import 'package:animeishi/ui/profile/services/qr_save_service.dart';

void main() {
  group('QRSaveService', () {
    test('ファイル名生成テスト', () {
      const username = 'testuser@example.com';
      final filename = QRSaveService.generateFilename(username);

      expect(filename.startsWith('animeishi_QR_'), isTrue);
      expect(filename.contains('testuser_at_example_'), isTrue);
    });

    test('短いユーザー名でのファイル名生成', () {
      const username = 'john';
      final filename = QRSaveService.generateFilename(username);

      expect(filename.startsWith('animeishi_QR_john'), isTrue);
    });

    test('権限チェック機能', () async {
      final permissions = await QRSaveService.checkPermissions();

      expect(permissions, isA<Map<String, dynamic>>());
      expect(permissions.containsKey('canSave'), isTrue);
      expect(permissions.containsKey('message'), isTrue);
    });

    test('異なるユーザー名で異なるファイル名が生成される', () {
      const username1 = 'alice@example.com';
      const username2 = 'bob@example.com';

      final filename1 = QRSaveService.generateFilename(username1);
      final filename2 = QRSaveService.generateFilename(username2);

      expect(filename1, isNot(equals(filename2)));
      expect(filename1.contains('alice'), isTrue);
      expect(filename2.contains('bob'), isTrue);
    });

    test('ファイル名に無効な文字が含まれていない', () {
      const username = 'user<>:"/\\|?*@example.com';
      final filename = QRSaveService.generateFilename(username);

      // ファイル名に使用できない文字が含まれていないかチェック
      expect(filename.contains(':'), isFalse);
      expect(filename.contains('?'), isFalse);
      expect(filename.contains('*'), isFalse);
      expect(filename.contains('<'), isFalse);
      expect(filename.contains('>'), isFalse);
      expect(filename.contains('|'), isFalse);
      expect(filename.contains('"'), isFalse);
      expect(filename.contains('/'), isFalse);
      expect(filename.contains('\\'), isFalse);

      // @はアンダースコアで置換されることを確認
      expect(filename.contains('_at_'), isTrue);
    });

    test('長いユーザー名は切り詰められる', () {
      const username = 'verylongusernamethatexceeds20characters@example.com';
      final filename = QRSaveService.generateFilename(username);

      // ファイル名が適切な長さに制限されることを確認
      expect(filename.startsWith('animeishi_QR_'), isTrue);
      final usernamePartLength =
          filename.replaceFirst('animeishi_QR_', '').length;
      expect(usernamePartLength, lessThanOrEqualTo(20));
    });
  });
}
