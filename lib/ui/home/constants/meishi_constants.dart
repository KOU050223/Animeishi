/// 名刺画像に関する定数
class MeishiConstants {
  /// 想定される名刺画像の実際のサイズ（幅）
  static const double originalWidth = 1075.0;

  /// 想定される名刺画像の実際のサイズ（高さ）
  static const double originalHeight = 650.0;

  /// 名刺画像の正確なアスペクト比 (1075:650)
  static const double aspectRatio = originalWidth / originalHeight;

  /// 名刺画像の表示幅（ホーム画面用）
  static const double imageWidth = 400.0;

  /// 名刺画像の表示高さ（アスペクト比に基づいて計算: 400 / 1.654 ≈ 242）
  static const double imageHeight = imageWidth / aspectRatio;

  /// 名刺画像の角丸半径
  static const double borderRadius = 8.0;

  /// 名刺画像のボーダー幅
  static const double borderWidth = 2.0;

  /// プレースホルダーのアイコンサイズ
  static const double placeholderIconSize = 32.0;

  /// プレースホルダーの小さなアイコンサイズ
  static const double placeholderSmallIconSize = 12.0;

  MeishiConstants._(); // プライベートコンストラクタ
}
