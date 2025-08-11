import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ErrorHandler {
  static String getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'このメールアドレスのアカウントは存在しません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'email-already-in-use':
        return 'このメールアドレスは既に使用されています';
      case 'weak-password':
        return 'パスワードが弱すぎます。8文字以上で設定してください';
      case 'invalid-email':
        return '無効なメールアドレスです';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'ログイン試行回数が上限に達しました。しばらくしてから再試行してください';
      case 'operation-not-allowed':
        return 'この認証方法は許可されていません';
      case 'invalid-credential':
        return '認証情報が無効です';
      case 'account-exists-with-different-credential':
        return '別の認証方法で登録されたアカウントが存在します';
      case 'requires-recent-login':
        return 'この操作には再ログインが必要です';
      case 'credential-already-in-use':
        return 'この認証情報は既に別のアカウントで使用されています';
      case 'network-request-failed':
        return 'ネットワーク接続を確認してください';
      default:
        return '認証エラーが発生しました。しばらくしてから再試行してください';
    }
  }

  static String getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'アクセス権限がありません。ログインしてから再試行してください';
      case 'unavailable':
        return 'サービスが一時的に利用できません。しばらくしてから再試行してください';
      case 'cancelled':
        return '操作がキャンセルされました';
      case 'deadline-exceeded':
        return '処理がタイムアウトしました。ネットワーク接続を確認してください';
      case 'already-exists':
        return 'データが既に存在します';
      case 'not-found':
        return '要求されたデータが見つかりません';
      case 'resource-exhausted':
        return 'リクエスト制限に達しました。しばらくしてから再試行してください';
      case 'failed-precondition':
        return 'データの前提条件が満たされていません';
      case 'aborted':
        return '処理が中断されました。再試行してください';
      case 'out-of-range':
        return '指定された範囲が無効です';
      case 'unimplemented':
        return 'この機能は現在利用できません';
      case 'internal':
        return 'サーバー内部エラーが発生しました';
      case 'data-loss':
        return 'データの破損が検出されました';
      case 'unauthenticated':
        return '認証が必要です。ログインしてください';
      default:
        return 'データの取得に失敗しました。しばらくしてから再試行してください';
    }
  }

  static String getGeneralErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return getFirebaseAuthErrorMessage(error);
    } else if (error is FirebaseException) {
      return getFirestoreErrorMessage(error);
    } else if (error.toString().contains('SocketException')) {
      return 'インターネット接続を確認してください';
    } else if (error.toString().contains('TimeoutException')) {
      return '処理がタイムアウトしました。再試行してください';
    } else if (error.toString().contains('FormatException')) {
      return '無効なデータ形式です';
    } else {
      return '予期しないエラーが発生しました。しばらくしてから再試行してください';
    }
  }

  static void logError(String context, dynamic error,
      [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('=== Error in $context ===');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
      print('========================');
    }

    // 本番環境では Firebase Crashlytics などにログ送信
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, context: context);
  }

  static void logInfo(String context, String message) {
    if (kDebugMode) {
      print('INFO [$context]: $message');
    }
  }

  static void logWarning(String context, String message) {
    if (kDebugMode) {
      print('WARNING [$context]: $message');
    }
  }

  // QRコード特有のエラー
  static String getQRErrorMessage(String errorType) {
    switch (errorType) {
      case 'invalid_format':
        return '無効なQRコードです';
      case 'self_scan':
        return '自分のQRコードはスキャンできません';
      case 'user_not_found':
        return 'このユーザーは存在しません';
      case 'already_friend':
        return '既にフレンドです';
      case 'scan_failed':
        return 'QRコードの読み取りに失敗しました';
      case 'camera_permission':
        return 'カメラの使用許可が必要です';
      default:
        return 'QRコードの処理中にエラーが発生しました';
    }
  }

  // アニメリスト特有のエラー
  static String getAnimeListErrorMessage(String errorType) {
    switch (errorType) {
      case 'fetch_failed':
        return 'アニメリストの取得に失敗しました';
      case 'save_failed':
        return 'アニメの保存に失敗しました';
      case 'delete_failed':
        return 'アニメの削除に失敗しました';
      case 'empty_selection':
        return 'アニメが選択されていません';
      case 'too_many_selections':
        return '選択できるアニメ数の上限に達しました';
      default:
        return 'アニメリストの処理中にエラーが発生しました';
    }
  }

  // プロフィール特有のエラー
  static String getProfileErrorMessage(String errorType) {
    switch (errorType) {
      case 'update_failed':
        return 'プロフィールの更新に失敗しました';
      case 'invalid_username':
        return 'ユーザー名が無効です';
      case 'username_too_long':
        return 'ユーザー名が長すぎます（20文字以内で入力してください）';
      case 'email_update_failed':
        return 'メールアドレスの更新に失敗しました';
      default:
        return 'プロフィールの処理中にエラーが発生しました';
    }
  }
}
