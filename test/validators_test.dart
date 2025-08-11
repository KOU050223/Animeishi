import 'package:flutter_test/flutter_test.dart';
import 'package:animeishi/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Email Validation', () {
      test('有効なメールアドレス', () {
        expect(Validators.validateEmail('test@example.com'), null);
        expect(Validators.validateEmail('user.name@domain.co.jp'), null);
        expect(Validators.validateEmail('test+tag@example.org'), null);
      });

      test('無効なメールアドレス', () {
        expect(Validators.validateEmail(''), 'メールアドレスを入力してください');
        expect(Validators.validateEmail(null), 'メールアドレスを入力してください');
        expect(
            Validators.validateEmail('invalid-email'), '有効なメールアドレスを入力してください');
        expect(Validators.validateEmail('test@'), '有効なメールアドレスを入力してください');
        expect(Validators.validateEmail('@example.com'), '有効なメールアドレスを入力してください');
        expect(Validators.validateEmail('test.example.com'),
            '有効なメールアドレスを入力してください');
      });
    });

    group('Password Validation', () {
      test('有効なパスワード', () {
        expect(Validators.validatePassword('password123'), null);
        expect(Validators.validatePassword('MySecure1'), null);
        expect(Validators.validatePassword('Test1234'), null);
      });

      test('無効なパスワード', () {
        expect(Validators.validatePassword(''), 'パスワードを入力してください');
        expect(Validators.validatePassword(null), 'パスワードを入力してください');
        expect(Validators.validatePassword('abc123'), 'パスワードは8文字以上で入力してください');
        expect(
            Validators.validatePassword('password'), 'パスワードは英字と数字を含む必要があります');
        expect(
            Validators.validatePassword('12345678'), 'パスワードは英字と数字を含む必要があります');
      });
    });

    group('User Name Validation', () {
      test('有効なユーザー名', () {
        expect(Validators.validateUserName('テストユーザー'), null);
        expect(Validators.validateUserName('ValidUser'), null);
        expect(Validators.validateUserName('ユーザー123'), null);
      });

      test('無効なユーザー名', () {
        expect(Validators.validateUserName(''), 'ユーザー名を入力してください');
        expect(Validators.validateUserName(null), 'ユーザー名を入力してください');
        expect(Validators.validateUserName('a'), 'ユーザー名は2文字以上で入力してください');
        expect(Validators.validateUserName('a' * 21), 'ユーザー名は20文字以内で入力してください');
      });
    });

    group('User ID Validation', () {
      test('有効なユーザーID', () {
        final validUserId = 'abcdefghijklmnopqrstuvwxyz12';
        expect(Validators.validateUserId(validUserId), null);
      });

      test('無効なユーザーID', () {
        expect(Validators.validateUserId(''), 'ユーザーIDが必要です');
        expect(Validators.validateUserId(null), 'ユーザーIDが必要です');
        expect(Validators.validateUserId('short'), '無効なユーザーIDです');
        expect(Validators.validateUserId('a' * 29), '無効なユーザーIDです');
      });
    });

    group('QR Data Validation', () {
      test('有効なQRデータ', () {
        final validUserId = 'abcdefghijklmnopqrstuvwxyz12';
        expect(Validators.validateQRData(validUserId), null);
      });

      test('無効なQRデータ', () {
        expect(Validators.validateQRData(''), 'QRコードデータが無効です');
        expect(Validators.validateQRData(null), 'QRコードデータが無効です');
        expect(Validators.validateQRData('invalid-data'), '無効なQRコードです');
      });
    });

    group('Utility Functions', () {
      test('メールアドレスの正規化', () {
        expect(Validators.normalizeEmail('  Test@Example.COM  '),
            'test@example.com');
      });

      test('ユーザー名の正規化', () {
        expect(Validators.normalizeUserName('  テストユーザー  '), 'テストユーザー');
      });
    });
  });
}
