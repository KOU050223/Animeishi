import 'package:flutter/material.dart';

/// プロフィールバリデーションサービス
class ProfileValidationService {
  /// ユーザー名のバリデーション
  static String? validateUsername(String username) {
    if (username.trim().isEmpty) {
      return 'ユーザー名を入力してください';
    }
    if (username.trim().length < 2) {
      return 'ユーザー名は2文字以上で入力してください';
    }
    if (username.trim().length > 20) {
      return 'ユーザー名は20文字以内で入力してください';
    }
    return null;
  }

  /// メールアドレスのバリデーション
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return '正しいメールアドレスの形式で入力してください';
    }
    return null;
  }

  /// 自己紹介のバリデーション
  static String? validateBio(String bio) {
    if (bio.trim().length > 500) {
      return '自己紹介は500文字以内で入力してください';
    }
    return null;
  }

  /// お気に入りの言葉のバリデーション
  static String? validateQuote(String quote) {
    if (quote.trim().length > 200) {
      return 'お気に入りの言葉は200文字以内で入力してください';
    }
    return null;
  }

  /// ジャンル選択のバリデーション
  static String? validateGenres(List<String> selectedGenres) {
    if (selectedGenres.isEmpty) {
      return '少なくとも1つのジャンルを選択してください';
    }
    if (selectedGenres.length > 10) {
      return 'ジャンルは10個まで選択できます';
    }
    return null;
  }

  /// プロフィール全体のバリデーション
  static ValidationResult validateProfile({
    required String username,
    required String email,
    required String bio,
    required String quote,
    required List<String> selectedGenres,
  }) {
    final errors = <String>[];

    final usernameError = validateUsername(username);
    if (usernameError != null) errors.add(usernameError);

    final emailError = validateEmail(email);
    if (emailError != null) errors.add(emailError);

    final bioError = validateBio(bio);
    if (bioError != null) errors.add(bioError);

    final quoteError = validateQuote(quote);
    if (quoteError != null) errors.add(quoteError);

    final genresError = validateGenres(selectedGenres);
    if (genresError != null) errors.add(genresError);

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }

  /// バリデーションエラーダイアログを表示
  static void showValidationDialog(BuildContext context, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('入力エラー'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('以下の項目を確認してください：'),
            SizedBox(height: 12),
            ...errors.map((error) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 6, color: Colors.red[600]),
                  SizedBox(width: 8),
                  Expanded(child: Text(error)),
                ],
              ),
            )).toList(),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: Text('確認'),
          ),
        ],
      ),
    );
  }

  /// 成功メッセージを表示
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  /// エラーメッセージを表示
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}

/// バリデーション結果を格納するクラス
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({
    required this.isValid,
    required this.errors,
  });
} 