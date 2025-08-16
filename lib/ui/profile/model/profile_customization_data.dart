import 'package:flutter/material.dart';

/// プロフィールカスタマイゼーション用の定数とデータ構造
class ProfileCustomizationData {
  // アニメジャンル
  static const List<String> allGenres = [
    'SF/ファンタジー',
    'ロボット/メカ',
    'アクション/バトル',
    'コメディ/ギャグ',
    '恋愛/ラブコメ',
    '日常/ほのぼの',
    'スポーツ/競技',
    'ホラー/サスペンス/推理',
    '歴史/戦記',
    '戦争/ミリタリー',
    'ドラマ/青春',
    'キッズ/ファミリー',
    'ショート',
    '2.5次元舞台',
    'ライブ/ラジオ/etc',
  ];

  // カラーテーマ
  static const List<Map<String, dynamic>> colorThemes = [
    {
      'name': 'オーロラ',
      'gradient': <Color>[Color(0xFF667eea), Color(0xFF764ba2)],
      'accent': Color(0xFF667eea),
    },
    {
      'name': 'サンセット',
      'gradient': <Color>[Color(0xFFf093fb), Color(0xFFf5576c)],
      'accent': Color(0xFFf093fb),
    },
    {
      'name': 'オーシャン',
      'gradient': <Color>[Color(0xFF4facfe), Color(0xFF00f2fe)],
      'accent': Color(0xFF4facfe),
    },
    {
      'name': 'フォレスト',
      'gradient': <Color>[Color(0xFF43e97b), Color(0xFF38f9d7)],
      'accent': Color(0xFF43e97b),
    },
    {
      'name': 'ラベンダー',
      'gradient': <Color>[Color(0xFFa8edea), Color(0xFFfed6e3)],
      'accent': Color(0xFFa8edea),
    },
    {
      'name': 'ゴールド',
      'gradient': <Color>[Color(0xFFffecd2), Color(0xFFfcb69f)],
      'accent': Color(0xFFffecd2),
    },
  ];

  // アバターアイコン
  static const List<IconData> avatarIcons = [
    Icons.person,
    Icons.sentiment_very_satisfied,
    Icons.pets,
    Icons.star,
    Icons.favorite,
    Icons.music_note,
    Icons.movie,
    Icons.gamepad,
    Icons.palette,
    Icons.auto_awesome,
  ];

  // パターン
  static const List<String> patterns = [
    'シンプル',
    'ドット',
    'ストライプ',
    'グラデーション',
    'キラキラ',
    'ハート',
  ];

  // 名刺スタイル
  static const List<Map<String, dynamic>> cardStyles = [
    {'name': 'クラシック', 'icon': Icons.credit_card},
    {'name': 'モダン', 'icon': Icons.style},
    {'name': 'エレガント', 'icon': Icons.auto_awesome},
    {'name': 'カジュアル', 'icon': Icons.emoji_emotions},
    {'name': 'プロフェッショナル', 'icon': Icons.business_center},
    {'name': 'アニメ風', 'icon': Icons.animation},
  ];

  // ボーダー
  static const List<String> borders = [
    'なし',
    'シンプル',
    'ダブル',
    'ドット',
    'グラデーション',
    'キラキラ',
  ];

  // ステッカー
  static const List<Map<String, dynamic>> availableStickers = [
    {'icon': '⭐', 'name': 'スター'},
    {'icon': '💖', 'name': 'ハート'},
    {'icon': '🌸', 'name': 'サクラ'},
    {'icon': '🎵', 'name': 'ミュージック'},
    {'icon': '🎮', 'name': 'ゲーム'},
    {'icon': '📺', 'name': 'アニメ'},
    {'icon': '🍀', 'name': 'クローバー'},
    {'icon': '🌟', 'name': 'キラキラ'},
    {'icon': '🎭', 'name': 'マスク'},
    {'icon': '🎨', 'name': 'アート'},
    {'icon': '⚡', 'name': 'ライトニング'},
    {'icon': '🔥', 'name': 'ファイア'},
  ];

  // エディター用の固定色
  static const Color editorPrimaryColor = Color(0xFF667eea);
  static const Color editorSecondaryColor = Color(0xFF764ba2);
  static const Color editorAccentColor = Color(0xFF667eea);
}

/// プロフィール設定データモデル
class ProfileCustomization {
  final int selectedTheme;
  final int selectedAvatar;
  final int selectedPattern;
  final int selectedCardStyle;
  final int selectedBorder;
  final double cardOpacity;
  final String favoriteQuote;
  final String profileImageUrl;
  final String bio;
  final List<Map<String, dynamic>> selectedStickers;

  const ProfileCustomization({
    this.selectedTheme = 0,
    this.selectedAvatar = 0,
    this.selectedPattern = 0,
    this.selectedCardStyle = 0,
    this.selectedBorder = 0,
    this.cardOpacity = 1.0,
    this.favoriteQuote = '',
    this.profileImageUrl = '',
    this.bio = '',
    this.selectedStickers = const [],
  });

  ProfileCustomization copyWith({
    int? selectedTheme,
    int? selectedAvatar,
    int? selectedPattern,
    int? selectedCardStyle,
    int? selectedBorder,
    double? cardOpacity,
    String? favoriteQuote,
    String? profileImageUrl,
    String? bio,
    List<Map<String, dynamic>>? selectedStickers,
  }) {
    return ProfileCustomization(
      selectedTheme: selectedTheme ?? this.selectedTheme,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
      selectedPattern: selectedPattern ?? this.selectedPattern,
      selectedCardStyle: selectedCardStyle ?? this.selectedCardStyle,
      selectedBorder: selectedBorder ?? this.selectedBorder,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      favoriteQuote: favoriteQuote ?? this.favoriteQuote,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      selectedStickers: selectedStickers ?? this.selectedStickers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardTheme': selectedTheme,
      'cardAvatar': selectedAvatar,
      'cardPattern': selectedPattern,
      'cardStyle': selectedCardStyle,
      'cardBorder': selectedBorder,
      'cardOpacity': cardOpacity,
      'favoriteQuote': favoriteQuote,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'stickers': selectedStickers,
    };
  }

  static ProfileCustomization fromJson(Map<String, dynamic> json) {
    return ProfileCustomization(
      selectedTheme: json['cardTheme'] ?? 0,
      selectedAvatar: json['cardAvatar'] ?? 0,
      selectedPattern: json['cardPattern'] ?? 0,
      selectedCardStyle: json['cardStyle'] ?? 0,
      selectedBorder: json['cardBorder'] ?? 0,
      cardOpacity: json['cardOpacity'] ?? 1.0,
      favoriteQuote: json['favoriteQuote'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      bio: json['bio'] ?? '',
      selectedStickers: List<Map<String, dynamic>>.from(json['stickers'] ?? []),
    );
  }
}
