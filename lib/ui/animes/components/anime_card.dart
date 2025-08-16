import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeCard extends StatefulWidget {
  final Map<String, dynamic> anime;
  final bool isSelected;
  final bool isRegistered;
  final VoidCallback onTap;
  final VoidCallback? onSelectToggle;
  final VoidCallback? onRemove;

  const AnimeCard({
    Key? key,
    required this.anime,
    required this.isSelected,
    required this.isRegistered,
    required this.onTap,
    this.onSelectToggle,
    this.onRemove,
  }) : super(key: key);

  @override
  _AnimeCardState createState() => _AnimeCardState();
}

class _AnimeCardState extends State<AnimeCard> with TickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = false;
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();

    _favoriteController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: Curves.elasticOut,
    ));

    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_user == null) return;

    try {
      final tid = widget.anime['tid']?.toString();
      if (tid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('favorites')
          .doc(tid)
          .get();

      if (mounted) {
        setState(() {
          _isFavorite = doc.exists;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_user == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tid = widget.anime['tid']?.toString();
      if (tid == null) return;

      final favoriteRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('favorites')
          .doc(tid);

      if (_isFavorite) {
        // お気に入りから削除
        await favoriteRef.delete();
        if (mounted) {
          setState(() {
            _isFavorite = false;
          });
        }
      } else {
        // お気に入りに追加
        await favoriteRef.set({
          'title': widget.anime['title'],
          'titleyomi': widget.anime['titleyomi'],
          'tid': widget.anime['tid'],
          'firstyear': widget.anime['firstyear'],
          'firstmonth': widget.anime['firstmonth'],
          'comment': widget.anime['comment'],
          'addedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
        }
      }

      // アニメーション実行
      _favoriteController.forward().then((_) {
        _favoriteController.reverse();
      });
    } catch (e) {
      print('Error toggling favorite: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 削除確認ダイアログを表示
  Future<void> _showRemoveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange[600],
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                '視聴済みから削除',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          content: Text(
            '「${widget.anime['title']}」を視聴済みリストから削除しますか？\n\nこの操作は取り消せません。',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'キャンセル',
                style: TextStyle(
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '削除',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == true && widget.onRemove != null) {
      widget.onRemove!();
    }
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tid = widget.anime['tid'] ?? 'N/A';
    final title = widget.anime['title'] ?? 'タイトル不明';
    final yomi = widget.anime['titleyomi'] ?? '';
    final firstMonth = widget.anime['firstmonth'] ?? '';
    final firstYear = widget.anime['firstyear'] ?? '';
    final comment = widget.anime['comment'] ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.isSelected
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
          color: widget.isSelected
              ? Color(0xFF667eea).withOpacity(0.5)
              : Colors.white.withOpacity(0.3),
          width: widget.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? Color(0xFF667eea).withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: widget.isSelected ? 20 : 15,
            offset: Offset(0, widget.isSelected ? 8 : 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
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
                          colors: widget.isRegistered
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
                            color: widget.isRegistered
                                ? Color(0xFF48BB78).withOpacity(0.3)
                                : Color(0xFF667eea).withOpacity(0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isRegistered
                            ? Icons.bookmark_added
                            : Icons.movie_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    // 登録済みバッジ
                    if (widget.isRegistered)
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

                    // お気に入りバッジ
                    if (_isFavorite)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: AnimatedBuilder(
                          animation: _favoriteAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _favoriteAnimation.value,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.pink[400]!,
                                      Colors.pink[600]!
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            );
                          },
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.isRegistered
                                  ? Color(0xFF48BB78).withOpacity(0.1)
                                  : Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'TID: $tid',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isRegistered
                                    ? Color(0xFF48BB78)
                                    : Color(0xFF667eea),
                              ),
                            ),
                          ),
                          if (widget.isRegistered) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
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

                // お気に入りボタン
                Container(
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isLoading ? null : _toggleFavorite,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.pink[400]!,
                                  ),
                                ),
                              )
                            : AnimatedBuilder(
                                animation: _favoriteAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _favoriteAnimation.value,
                                    child: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorite
                                          ? Colors.pink[400]
                                          : Colors.grey[600],
                                      size: 16,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),

                // 削除ボタン（登録済みの場合のみ表示）
                if (widget.isRegistered && widget.onRemove != null)
                  Container(
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _showRemoveDialog,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 選択状態インジケーター（登録済みでない場合のみ表示）
                if (!widget.isRegistered && widget.onSelectToggle != null)
                  GestureDetector(
                    onTap: widget.onSelectToggle,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? Color(0xFF667eea)
                            : Colors.transparent,
                        border: Border.all(
                          color: widget.isSelected
                              ? Color(0xFF667eea)
                              : Color(0xFF718096).withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.isSelected
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
