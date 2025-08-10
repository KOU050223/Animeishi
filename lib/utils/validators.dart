import 'package:flutter/material.dart';

class Validators {
  // メールアドレスのバリデーション
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }

    // より厳密なメールアドレスの正規表現
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$');

    if (!emailRegex.hasMatch(value.trim())) {
      return '有効なメールアドレスを入力してください';
    }

    // 長さ制限（一般的なメールアドレスの最大長）
    if (value.trim().length > 254) {
      return 'メールアドレスが長すぎます';
    }

    return null;
  }

  // パスワードのバリデーション
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }

    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }

    if (value.length > 128) {
      return 'パスワードは128文字以内で入力してください';
    }

    // 英字と数字を含むことをチェック
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'パスワードは英字と数字を含む必要があります';
    }

    // 一般的に脆弱とされるパスワードパターンをチェック
    final weakPatterns = [
      RegExp(r'^(.)\1{7,}$'), // 同じ文字の繰り返し
      RegExp(r'^(password|12345678|qwerty|abc123|letmein|admin|user)$',
          caseSensitive: false),
    ];

    for (final pattern in weakPatterns) {
      if (pattern.hasMatch(value)) {
        return 'より安全なパスワードを設定してください';
      }
    }

    return null;
  }

  // パスワード確認のバリデーション
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'パスワードを再入力してください';
    }

    if (value != password) {
      return 'パスワードが一致しません';
    }

    return null;
  }

  // 必須項目のバリデーション
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldNameを入力してください';
    }
    return null;
  }

  // ユーザー名のバリデーション
  static String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ユーザー名を入力してください';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'ユーザー名は2文字以上で入力してください';
    }

    if (trimmedValue.length > 20) {
      return 'ユーザー名は20文字以内で入力してください';
    }

    // 使用可能文字のチェック（日本語、英数字、一部記号）
    if (!RegExp(
            r'^[a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF\u002D\u005F\u0020]+$')
        .hasMatch(trimmedValue)) {
      return 'ユーザー名に使用できない文字が含まれています';
    }

    // 不適切な文字列のチェック
    final inappropriateWords = [
      'admin',
      'root',
      'test',
      'system',
      'null',
      'undefined'
    ];
    for (final word in inappropriateWords) {
      if (trimmedValue.toLowerCase().contains(word)) {
        return '別のユーザー名を選択してください';
      }
    }

    return null;
  }

  // ユーザーIDのバリデーション（Firebase Auth UID）
  static String? validateUserId(String? value) {
    if (value == null || value.isEmpty) {
      return 'ユーザーIDが必要です';
    }

    // Firebase Auth UID の形式チェック（28文字の英数字）
    if (!RegExp(r'^[a-zA-Z0-9]{28}$').hasMatch(value)) {
      return '無効なユーザーIDです';
    }

    return null;
  }

  // ジャンル選択のバリデーション
  static String? validateGenre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ジャンルを選択してください';
    }

    // 定義済みのジャンルリスト
    final validGenres = [
      'アクション',
      'コメディ',
      'ドラマ',
      'ファンタジー',
      'ホラー',
      'ミステリー',
      'ロマンス',
      'SF',
      'スポーツ',
      'アドベンチャー',
      'スリラー',
      '歴史',
      '音楽',
      '日常系',
      '異世界'
    ];

    if (!validGenres.contains(value.trim())) {
      return '有効なジャンルを選択してください';
    }

    return null;
  }

  // QRコードデータのバリデーション
  static String? validateQRData(String? value) {
    if (value == null || value.isEmpty) {
      return 'QRコードデータが無効です';
    }

    // URLスキーマのチェック（例: animeishi://user/{userId}）
    final uri = Uri.tryParse(value);
    if (uri != null &&
        uri.scheme == 'animeishi' &&
        uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'user') {
        return validateUserId(uri.pathSegments[1]);
      }
    }

    // 直接ユーザーIDの場合
    if (RegExp(r'^[a-zA-Z0-9]{28}$').hasMatch(value)) {
      return validateUserId(value);
    }

    return '無効なQRコードです';
  }

  // 年のバリデーション（アニメの放送年）
  static String? validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 年は必須ではない
    }

    final year = int.tryParse(value);
    if (year == null) {
      return '有効な年を入力してください';
    }

    final currentYear = DateTime.now().year;
    if (year < 1950 || year > currentYear + 5) {
      return '1950年から${currentYear + 5}年の間で入力してください';
    }

    return null;
  }

  // 文字数制限のバリデーション
  static String? validateLength(
      String? value, String fieldName, int minLength, int maxLength) {
    if (value == null) {
      return '$fieldNameを入力してください';
    }

    if (value.trim().length < minLength) {
      return '$fieldNameは$minLength文字以上で入力してください';
    }

    if (value.trim().length > maxLength) {
      return '$fieldNameは$maxLength文字以内で入力してください';
    }

    return null;
  }

  // コメントのバリデーション
  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // コメントは任意
    }

    if (value.trim().length > 500) {
      return 'コメントは500文字以内で入力してください';
    }

    // 不適切な内容のチェック（基本的なもの）
    final inappropriatePatterns = [
      RegExp(r'(死ね|殺す|バカ|アホ)', caseSensitive: false),
      RegExp(r'https?://[^\s]+'), // URL の投稿を制限
    ];

    for (final pattern in inappropriatePatterns) {
      if (pattern.hasMatch(value)) {
        return '不適切な内容が含まれています';
      }
    }

    return null;
  }

  // 複数バリデーションの実行
  static String? validateMultiple(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // フォーム全体のバリデーション
  static bool isFormValid(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  // メールアドレスの正規化
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // ユーザー名の正規化
  static String normalizeUserName(String userName) {
    return userName.trim();
  }
}
