import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/anime_list_view_model.dart';
import '../components/anime_card.dart';
import '../components/anime_list_header.dart';
import '../components/anime_notification.dart';
import 'package:animeishi/model/factory/anime_list_factory.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/components/auth_widgets.dart';

class AnimeListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = AnimeListViewModel();
        viewModel.fetchFromServer();
        return viewModel;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD6BCFA), // ソフトパープル
                Color(0xFFBFDBFE), // ソフトブルー
                Color(0xFFFBCFE8), // ソフトピンク
                Color(0xFFD1FAE5), // ソフトグリーン
              ],
            ),
          ),
          child: Consumer<AnimeListViewModel>(
            builder: (context, viewModel, child) {
              return CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // カスタムAppBar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => HomePage()),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF667eea),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.movie_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'アニメリスト',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ヘッダー部分
                  SliverToBoxAdapter(
                    child: AnimeListHeader(
                      viewModel: viewModel,
                      onFetchFromServer: () => _handleFetchFromServer(context, viewModel),
                      onDeleteSelected: () => _handleDeleteSelected(context, viewModel),
                      onSaveSelected: () => _handleSaveSelected(context, viewModel),
                    ),
                  ),

                  // アニメリスト
                  SliverPadding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    sliver: viewModel.animeList.isEmpty
                        ? SliverToBoxAdapter(
                            child: _buildEmptyState(),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final anime = viewModel.animeList[index];
                                final tid = anime['tid'] ?? 'N/A';
                                final isSelected = viewModel.selectedAnime.contains(tid);
                                final isRegistered = viewModel.registeredAnime.contains(tid);

                                return AnimeCard(
                                  anime: anime,
                                  isSelected: isSelected,
                                  isRegistered: isRegistered,
                                  onTap: () {
                                    if (isRegistered) {
                                      // 登録済みアニメの場合は削除確認
                                      _showUnregisterDialog(context, viewModel, tid, anime['title'] ?? 'タイトル不明');
                                    } else if (isSelected) {
                                      viewModel.deselectAnime(tid);
                                    } else {
                                      viewModel.selectAnime(tid);
                                    }
                                  },
                                );
                              },
                              childCount: viewModel.animeList.length,
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF667eea).withOpacity(0.2),
                  Color(0xFF764ba2).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.movie_outlined,
              size: 40,
              color: Color(0xFF667eea).withOpacity(0.6),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'アニメリストが空です',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '「オンラインから取得」ボタンを押して\nアニメデータを読み込んでください',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _handleFetchFromServer(BuildContext context, AnimeListViewModel viewModel) async {
    try {
      await viewModel.fetchFromServer();
      final count = viewModel.animeList.length;
      AnimeNotification.showSuccess(
        context, 
        'オンライン取得完了',
        subtitle: '$count件のアニメを取得しました',
      );
    } catch (e) {
      AnimeNotification.showError(
        context, 
        '取得エラー',
        subtitle: 'データの取得に失敗しました',
      );
    }
  }

  Future<void> _handleDeleteSelected(BuildContext context, AnimeListViewModel viewModel) async {
    try {
      final selectedCount = viewModel.selectedAnime.length;
      await viewModel.deleteSelectedAnime();
      AnimeNotification.showInfo(
        context, 
        'アニメ削除完了',
        subtitle: '$selectedCount件のアニメを削除しました',
      );
    } catch (e) {
      AnimeNotification.showError(
        context, 
        '削除エラー',
        subtitle: 'アニメの削除に失敗しました',
      );
    }
  }

  Future<void> _handleSaveSelected(BuildContext context, AnimeListViewModel viewModel) async {
    try {
      final selectedCount = viewModel.selectedAnime.length;
      await viewModel.saveSelectedAnime();
      AnimeNotification.showSuccess(
        context, 
        'アニメ登録完了',
        subtitle: '$selectedCount件のアニメを登録しました',
      );
    } catch (e) {
      AnimeNotification.showError(
        context, 
        '登録エラー',
        subtitle: 'アニメの登録に失敗しました',
      );
        }
  }

  void _showUnregisterDialog(BuildContext context, AnimeListViewModel viewModel, String tid, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFf093fb).withOpacity(0.8),
                        Color(0xFFf5576c).withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.bookmark_remove,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                
                SizedBox(height: 20),
                
                Text(
                  '登録解除確認',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                
                SizedBox(height: 12),
                
                Text(
                  '「$title」を登録から解除しますか？',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(height: 24),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(),
                            child: Center(
                              child: Text(
                                'キャンセル',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFf093fb).withOpacity(0.8),
                              Color(0xFFf5576c).withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFf093fb).withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await _handleUnregisterSingle(context, viewModel, tid, title);
                            },
                            child: Center(
                              child: Text(
                                '解除',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleUnregisterSingle(BuildContext context, AnimeListViewModel viewModel, String tid, String title) async {
    try {
      // 一時的に選択状態にして削除処理を実行
      viewModel.selectAnime(tid);
      await viewModel.deleteSelectedAnime();
      
      AnimeNotification.showInfo(
        context, 
        'アニメ登録解除完了',
        subtitle: '「$title」を登録から解除しました',
      );
    } catch (e) {
      AnimeNotification.showError(
        context, 
        '解除エラー',
        subtitle: 'アニメの登録解除に失敗しました',
      );
    }
  }

 
}
