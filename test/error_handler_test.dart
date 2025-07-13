import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animeishi/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    group('Firebase Auth Error Messages', () => {
      test('user-not-found エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'user-not-found');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, 'このメールアドレスのアカウントは存在しません');
      }),

      test('wrong-password エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'wrong-password');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, 'パスワードが間違っています');
      }),

      test('email-already-in-use エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, 'このメールアドレスは既に使用されています');
      }),

      test('weak-password エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'weak-password');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, 'パスワードが弱すぎます。8文字以上で設定してください');
      }),

      test('invalid-email エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'invalid-email');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, '無効なメールアドレスです');
      }),

      test('network-request-failed エラーメッセージ', () {
        final exception = FirebaseAuthException(code: 'network-request-failed');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, 'ネットワーク接続を確認してください');
      }),

      test('未知のエラーコード', () {
        final exception = FirebaseAuthException(code: 'unknown-error');
        final message = ErrorHandler.getFirebaseAuthErrorMessage(exception);
        expect(message, '認証エラーが発生しました。しばらくしてから再試行してください');
      }),
    });

    group('Firestore Error Messages', () => {
      test('permission-denied エラーメッセージ', () {
        final exception = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        );
        final message = ErrorHandler.getFirestoreErrorMessage(exception);
        expect(message, 'アクセス権限がありません。ログインしてから再試行してください');
      }),

      test('unavailable エラーメッセージ', () {
        final exception = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        );
        final message = ErrorHandler.getFirestoreErrorMessage(exception);
        expect(message, 'サービスが一時的に利用できません。しばらくしてから再試行してください');
      }),

      test('not-found エラーメッセージ', () {
        final exception = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
        );
        final message = ErrorHandler.getFirestoreErrorMessage(exception);
        expect(message, '要求されたデータが見つかりません');
      }),

      test('deadline-exceeded エラーメッセージ', () {
        final exception = FirebaseException(
          plugin: 'cloud_firestore',
          code: 'deadline-exceeded',
        );
        final message = ErrorHandler.getFirestoreErrorMessage(exception);
        expect(message, '処理がタイムアウトしました。ネットワーク接続を確認してください');
      }),
    });

    group('General Error Messages', () => {
      test('SocketException エラー', () {
        final error = Exception('SocketException: Failed host lookup');
        final message = ErrorHandler.getGeneralErrorMessage(error);
        expect(message, 'インターネット接続を確認してください');
      }),

      test('TimeoutException エラー', () {
        final error = Exception('TimeoutException: Request timeout');
        final message = ErrorHandler.getGeneralErrorMessage(error);
        expect(message, '処理がタイムアウトしました。再試行してください');
      }),

      test('FormatException エラー', () {
        final error = Exception('FormatException: Invalid format');
        final message = ErrorHandler.getGeneralErrorMessage(error);
        expect(message, '無効なデータ形式です');
      }),

      test('未知のエラー', () {
        final error = Exception('Unknown error');
        final message = ErrorHandler.getGeneralErrorMessage(error);
        expect(message, '予期しないエラーが発生しました。しばらくしてから再試行してください');
      }),
    });

    group('QR Code Error Messages', () => {
      test('invalid_format エラー', () {
        final message = ErrorHandler.getQRErrorMessage('invalid_format');
        expect(message, '無効なQRコードです');
      }),

      test('self_scan エラー', () {
        final message = ErrorHandler.getQRErrorMessage('self_scan');
        expect(message, '自分のQRコードはスキャンできません');
      }),

      test('user_not_found エラー', () {
        final message = ErrorHandler.getQRErrorMessage('user_not_found');
        expect(message, 'このユーザーは存在しません');
      }),

      test('already_friend エラー', () {
        final message = ErrorHandler.getQRErrorMessage('already_friend');
        expect(message, '既にフレンドです');
      }),
    });

    group('Anime List Error Messages', () => {
      test('fetch_failed エラー', () {
        final message = ErrorHandler.getAnimeListErrorMessage('fetch_failed');
        expect(message, 'アニメリストの取得に失敗しました');
      }),

      test('save_failed エラー', () {
        final message = ErrorHandler.getAnimeListErrorMessage('save_failed');
        expect(message, 'アニメの保存に失敗しました');
      }),

      test('empty_selection エラー', () {
        final message = ErrorHandler.getAnimeListErrorMessage('empty_selection');
        expect(message, 'アニメが選択されていません');
      }),
    });

    group('Profile Error Messages', () => {
      test('update_failed エラー', () {
        final message = ErrorHandler.getProfileErrorMessage('update_failed');
        expect(message, 'プロフィールの更新に失敗しました');
      }),

      test('invalid_username エラー', () {
        final message = ErrorHandler.getProfileErrorMessage('invalid_username');
        expect(message, 'ユーザー名が無効です');
      }),

      test('username_too_long エラー', () {
        final message = ErrorHandler.getProfileErrorMessage('username_too_long');
        expect(message, 'ユーザー名が長すぎます（20文字以内で入力してください）');
      }),
    });
  });
}