import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/anime_image_service.dart';
import '../services/comment_parser_service.dart';

/// アニメ詳細画面のUI構築ヘルパークラス
class AnimeDetailWidgets {
  /// メインのヒーローカードを構築
  static Widget buildHeroCard({
    required Map<String, dynamic> anime,
    required bool isFavorite,
    required bool isLoading,
    required VoidCallback onFavoritePressed,
    Widget? favoriteAnimationWidget,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // アニメ画像とお気に入りバッジ
          _buildAnimeImageWithFavoriteBadge(
              anime, isFavorite, favoriteAnimationWidget),

          const SizedBox(height: 20),

          // タイトル
          _buildAnimeTitle(anime['title']),

          const SizedBox(height: 12),

          // 読み仮名
          _buildAnimeTitleYomi(anime['titleyomi']),

          const SizedBox(height: 16),

          // お気に入りボタン
          _buildFavoriteButton(
            isFavorite: isFavorite,
            isLoading: isLoading,
            onPressed: onFavoritePressed,
            favoriteAnimationWidget: favoriteAnimationWidget,
          ),
        ],
      ),
    );
  }

  /// 詳細情報カードを構築
  static Widget buildDetailsCard({
    required Map<String, dynamic> anime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // セクションヘッダー
          _buildSectionHeader('詳細情報', Icons.info_outline),

          const SizedBox(height: 20),

          // 基本情報
          _buildBasicInfo(anime),

          const SizedBox(height: 24),

          // コメント詳細
          _buildCommentSection(anime['comment']),
        ],
      ),
    );
  }

  /// アニメ画像とお気に入りバッジの構築
  static Widget _buildAnimeImageWithFavoriteBadge(Map<String, dynamic> anime,
      bool isFavorite, Widget? favoriteAnimationWidget) {
    return Stack(
      children: [
        FutureBuilder<String?>(
          future: AnimeImageService.getImageUrl(anime['tid']?.toString() ?? ''),
          builder: (context, snapshot) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth.isInfinite
                    ? 400.0
                    : constraints.maxWidth;
                final containerWidth = maxWidth > 400 ? 400.0 : maxWidth;
                final containerHeight = containerWidth * 4 / 3; // 3:4の縦長比率

                return Container(
                  width: containerWidth,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.4),
                        blurRadius: 25,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : snapshot.data != null
                            ? CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    ),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2)
                                      ],
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2)
                                    ],
                                  ),
                                ),
                                child: const Icon(
                                  Icons.play_circle_filled,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                  ),
                );
              },
            );
          },
        ),

        // お気に入りバッジ
        if (isFavorite && favoriteAnimationWidget != null)
          Positioned(
            top: -5,
            right: -5,
            child: favoriteAnimationWidget,
          ),
      ],
    );
  }

  /// アニメタイトルの構築
  static Widget _buildAnimeTitle(String? title) {
    return Text(
      title ?? 'タイトル不明',
      style: TextStyle(
        color: Colors.grey.shade800,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// アニメ読み仮名の構築
  static Widget _buildAnimeTitleYomi(String? titleYomi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.1),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF667EEA).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        titleYomi ?? '読み仮名不明',
        style: const TextStyle(
          color: Color(0xFF667EEA),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// お気に入りボタンの構築
  static Widget _buildFavoriteButton({
    required bool isFavorite,
    required bool isLoading,
    required VoidCallback onPressed,
    Widget? favoriteAnimationWidget,
  }) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : favoriteAnimationWidget ??
                Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
        label: Text(
          isFavorite ? 'お気に入り登録済み' : 'お気に入りに追加',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isFavorite ? Colors.pink[400] : Colors.grey[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor:
              (isFavorite ? Colors.pink : Colors.grey).withOpacity(0.3),
        ),
      ),
    );
  }

  /// セクションヘッダーの構築
  static Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 基本情報の構築
  static Widget _buildBasicInfo(Map<String, dynamic> anime) {
    return Column(
      children: [
        if (anime['firstyear'] != null || anime['firstmonth'] != null)
          _buildInfoRow(
            '放送開始',
            '${anime['firstyear'] ?? '不明'}年 ${anime['firstmonth'] ?? '不明'}月',
            Icons.calendar_today,
          ),
        if (anime['tid'] != null)
          _buildInfoRow(
            'アニメID',
            anime['tid'].toString(),
            Icons.tag,
          ),
      ],
    );
  }

  /// 情報行の構築
  static Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF667EEA),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// コメントセクションの構築
  static Widget _buildCommentSection(String? comment) {
    if (comment == null || comment.trim().isEmpty) {
      return _buildEmptyCommentState();
    }

    final sections = CommentParserService.parseComment(comment);

    if (sections.isEmpty) {
      return _buildEmptyCommentState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections
                .map((section) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: CommentParserService.buildCommentSection(section),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// 空のコメント状態の構築
  static Widget _buildEmptyCommentState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey.shade500,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              '詳細情報はありません',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
