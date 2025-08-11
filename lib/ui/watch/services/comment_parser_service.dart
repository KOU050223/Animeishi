import 'package:flutter/material.dart';

/// コメント解析サービス
class CommentParserService {
  /// コメントをセクションに分けて解析する
  static List<CommentSection> parseComment(String comment) {
    if (comment.trim().isEmpty) {
      return [];
    }

    final sections = <CommentSection>[];
    final lines = comment.split('\n');

    String currentSectionTitle = '';
    List<String> currentContent = [];

    for (String line in lines) {
      if (line.startsWith('*')) {
        // 新しいセクションの開始
        if (currentSectionTitle.isNotEmpty) {
          sections.add(CommentSection(
            title: currentSectionTitle,
            content: List.from(currentContent),
          ));
        }
        currentSectionTitle = line.substring(1).trim(); // '*'を除去
        currentContent = [];
      } else if (line.trim().isNotEmpty) {
        currentContent.add(line);
      }
    }

    // 最後のセクションを追加
    if (currentSectionTitle.isNotEmpty) {
      sections.add(CommentSection(
        title: currentSectionTitle,
        content: List.from(currentContent),
      ));
    }

    return sections;
  }

  /// コメント行のタイプを判定する
  static CommentLineType getLineType(String line) {
    if (line.startsWith('-')) {
      return CommentLineType.bulletPoint;
    } else if (line.startsWith('[') && line.contains(']')) {
      return CommentLineType.link;
    } else {
      return CommentLineType.normal;
    }
  }

  /// リンクテキストを解析する
  static LinkInfo? parseLink(String line) {
    if (!line.startsWith('[') || !line.contains(']')) {
      return null;
    }

    final bracketEnd = line.indexOf(']');
    final linkText = line.substring(1, bracketEnd);
    final description = line.length > bracketEnd + 1
        ? line.substring(bracketEnd + 1).trim()
        : '';

    return LinkInfo(
      text: linkText,
      description: description,
      fullLine: line,
    );
  }

  /// コメントセクションウィジェットを構築する
  static Widget buildCommentSection(CommentSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションタイトル
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667EEA).withOpacity(0.1),
                Color(0xFF764BA2).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFF667EEA).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF667EEA),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                section.title,
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),

        // セクション内容
        ...section.content.map((line) => buildCommentLine(line)).toList(),
      ],
    );
  }

  /// コメント行のウィジェットを構築する
  static Widget buildCommentLine(String line) {
    final lineType = getLineType(line);

    switch (lineType) {
      case CommentLineType.bulletPoint:
        return _buildBulletPoint(line);
      case CommentLineType.link:
        return _buildLinkLine(line);
      case CommentLineType.normal:
        return _buildNormalLine(line);
    }
  }

  static Widget _buildBulletPoint(String line) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              line.substring(1).trim(), // '-'を除去
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLinkLine(String line) {
    final linkInfo = parseLink(line);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.link,
              color: Colors.blue.shade600,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    linkInfo?.text ?? line,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (linkInfo != null && linkInfo.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        linkInfo.description,
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildNormalLine(String line) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        line,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

/// コメントセクション情報
class CommentSection {
  final String title;
  final List<String> content;

  CommentSection({
    required this.title,
    required this.content,
  });
}

/// コメント行のタイプ
enum CommentLineType {
  normal,
  bulletPoint,
  link,
}

/// リンク情報
class LinkInfo {
  final String text;
  final String description;
  final String fullLine;

  LinkInfo({
    required this.text,
    required this.description,
    required this.fullLine,
  });
}
