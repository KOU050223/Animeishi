import 'package:flutter_test/flutter_test.dart';
import 'package:animeishi/ui/camera/services/scan_data_service.dart';

void main() {
  group('ScanDataService', () {
    group('extractUserIdFromQR', () {
      test('URL形式のQRコードから正しくユーザーIDを抽出する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/test-user-id-123';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('test-user-id-123'));
      });

      test('URL形式のQRコードから複雑なユーザーIDを抽出する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/ABC123def456GHI789';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('ABC123def456GHI789'));
      });

      test('直接ユーザーIDが渡された場合は従来通り動作する', () {
        // Arrange
        const qrValue = 'direct-user-id';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('direct-user-id'));
      });

      test('nullが渡された場合はnullを返す', () {
        // Act
        final result = ScanDataService.extractUserIdFromQR(null);
        
        // Assert
        expect(result, isNull);
      });

      test('空文字列が渡された場合はnullを返す', () {
        // Act
        final result = ScanDataService.extractUserIdFromQR('');
        
        // Assert
        expect(result, isNull);
      });

      test('空白のみの文字列が渡された場合はnullを返す', () {
        // Act
        final result = ScanDataService.extractUserIdFromQR('   ');
        
        // Assert
        expect(result, isNull);
      });

      test('短すぎるユーザーIDが渡された場合はnullを返す', () {
        // Act
        final result = ScanDataService.extractUserIdFromQR('ab');
        
        // Assert
        expect(result, isNull);
      });

      test('URL形式だがユーザーIDが空の場合はnullを返す', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, isNull);
      });

      test('前後に空白があるURL形式のQRコードを正しく処理する', () {
        // Arrange
        const qrValue = '  https://animeishi-viewer.web.app/user/trimmed-user-id  ';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('trimmed-user-id'));
      });

      test('異なるURLフォーマットの場合は従来の動作をする', () {
        // Arrange
        const qrValue = 'https://example.com/user/some-id';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('https://example.com/user/some-id'));
      });

      test('FirebaseのUID形式のQRコードを正しく処理する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/1A2B3C4D5E6F7G8H9I0J';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('1A2B3C4D5E6F7G8H9I0J'));
      });

      test('URL形式でスラッシュが複数ある場合も正しく処理する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/uid/with/slashes';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('uid/with/slashes'));
      });

      test('最小有効長のユーザーIDを正しく処理する', () {
        // Arrange
        const qrValue = 'abc';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('abc'));
      });

      test('HTTPSではないURLの場合は従来の動作をする', () {
        // Arrange
        const qrValue = 'http://animeishi-viewer.web.app/user/test-id';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('http://animeishi-viewer.web.app/user/test-id'));
      });

      test('URLパターンが似ているが異なるドメインの場合は従来の動作をする', () {
        // Arrange
        const qrValue = 'https://fake-animeishi-viewer.web.app/user/test-id';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('https://fake-animeishi-viewer.web.app/user/test-id'));
      });

      test('QRコードにクエリパラメータが含まれている場合も正しく処理する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/test-id?ref=qr';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('test-id?ref=qr'));
      });

      test('ユーザーIDにハイフンやアンダースコアが含まれる場合も正しく処理する', () {
        // Arrange
        const qrValue = 'https://animeishi-viewer.web.app/user/user-id_with-special_chars';
        
        // Act
        final result = ScanDataService.extractUserIdFromQR(qrValue);
        
        // Assert
        expect(result, equals('user-id_with-special_chars'));
      });
    });
  });
}