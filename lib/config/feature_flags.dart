import 'package:flutter/foundation.dart';

/// アプリケーションの機能フラグを管理するクラス
/// 開発・テスト用の機能を本番環境では無効にするために使用
class FeatureFlags {
  /// デバッグモードかどうかを判定
  /// 開発時（debug build）ではtrue、リリース時（release build）ではfalse
  static const bool _isDebugMode = kDebugMode;

  /// テスト機能を有効にするかどうか
  /// 本番環境では常にfalse、デバッグ時のみtrue
  static const bool enableTestFeatures = _isDebugMode;

  /// テストログイン機能を有効にするかどうか
  static const bool enableTestLogin = enableTestFeatures;

  /// アニメテストデータ作成機能を有効にするかどうか
  static const bool enableTestDataCreation = enableTestFeatures;

  /// デバッグ用ログ出力を有効にするかどうか
  static const bool enableDebugLogs = enableTestFeatures;
}
