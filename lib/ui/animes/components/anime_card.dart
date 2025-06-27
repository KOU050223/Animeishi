import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  final Map<String, dynamic> anime;
  final bool isSelected;
  final bool isRegistered;
  final VoidCallback onTap;

  const AnimeCard({
    Key? key,
    required this.anime,
    required this.isSelected,
    required this.isRegistered,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tid = anime['tid'] ?? 'N/A';
    final title = anime['title'] ?? 'タイトル不明';
    final yomi = anime['titleyomi'] ?? '';
    final firstMonth = anime['firstmonth'] ?? '';
    final firstYear = anime['firstyear'] ?? '';
    final comment = anime['comment'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSelected
              ? [
                  Color(0xFF667eea).withOpacity(0.15),
                  Color(0xFF764ba2).withOpacity(0.1),
                ]
              : [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? Color(0xFF667eea).withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? Color(0xFF667eea).withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 20 : 15,
            offset: Offset(0, isSelected ? 8 : 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                // アニメアイコン
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isRegistered
                              ? [
                                  Color(0xFF48BB78).withOpacity(0.9),
                                  Color(0xFF38A169).withOpacity(0.9),
                                ]
                              : [
                                  Color(0xFF667eea).withOpacity(0.8),
                                  Color(0xFF764ba2).withOpacity(0.9),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isRegistered
                                ? Color(0xFF48BB78).withOpacity(0.3)
                                : Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        isRegistered ? Icons.bookmark_added : Icons.movie_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    // 登録済みバッジ
                    if (isRegistered)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF48BB78),
                                Color(0xFF38A169),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF48BB78).withOpacity(0.4),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                
                SizedBox(width: 16),
                
                // アニメ情報
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトル
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3748),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 4),
                      
                      // TID表示と登録済みステータス
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isRegistered
                                  ? Color(0xFF48BB78).withOpacity(0.1)
                                  : Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TID: $tid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isRegistered
                                    ? Color(0xFF48BB78)
                                    : Color(0xFF667eea),
                              ),
                            ),
                          ),
                          
                          if (isRegistered) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF48BB78),
                                    Color(0xFF38A169),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF48BB78).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.bookmark_added,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '登録済み',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      SizedBox(height: 8),
                      
                      // 年月表示
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Color(0xFF718096),
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$firstYear年$firstMonth月',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      // コメントがある場合は表示
                      if (comment.isNotEmpty) ...[
                        SizedBox(height: 6),
                        Text(
                          comment,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(width: 12),
                
                // 選択状態インジケーター
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color(0xFF667eea)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF667eea)
                          : Color(0xFF718096).withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 