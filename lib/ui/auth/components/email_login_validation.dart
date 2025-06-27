import 'package:flutter/material.dart';

class EmailLoginValidation {
  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'メールアドレスを入力してください';
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return '正しいメールアドレスを入力してください';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'パスワードを入力してください';
    }
    return null;
  }

  static String getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'このメールアドレスは登録されていません';
      case 'wrong-password':
        return 'パスワードが間違っています';
      case 'invalid-email':
        return '無効なメールアドレスです';
      case 'user-disabled':
        return 'このアカウントは無効化されています';
      case 'too-many-requests':
        return 'ログイン試行回数が多すぎます。しばらく待ってからお試しください';
      case 'network-request-failed':
        return 'ネットワークエラーが発生しました';
      default:
        return 'ログインに失敗しました';
    }
  }
} 