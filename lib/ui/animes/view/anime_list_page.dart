import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/anime_list_view_model.dart';
import '../components/anime_card.dart';
import '../components/anime_list_header.dart';
import '../components/anime_notification.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/watch/view/watch_anime.dart';

class AnimeListPage extends StatelessWidget {
  const AnimeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // アプリケーション全体で共有されているViewModelを使用
    final viewModel = Provider.of<AnimeListViewModel>(context, listen: false);

    // 初回のみフェッチ
    if (!viewModel.isLoading && viewModel.animeList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.fetchFromServer();
      });
    }

    return Scaffold(
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
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      onFetchFromServer: () =>
                          _handleFetchFromServer(context, viewModel),
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
                                final isSelected =
                                    viewModel.selectedAnime.contains(tid);
                                final isRegistered =
                                    viewModel.registeredAnime.contains(tid);

                                // 登録済みアニメの場合はスワイプで削除可能にする
                                if (isRegistered) {
                                  return Dismissible(
                                    key: Key('anime_$tid'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red[400]!,
                                            Colors.red[600]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(right: 30),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '削除',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      return await _showUnregisterDialog(
                                          context,
                                          viewModel,
                                          tid,
                                          anime['title'] ?? 'タイトル不明');
                                    },
                                    child: _buildAnimeCard(context, anime,
                                        isSelected, isRegistered, viewModel),
                                  );
                                } else {
                                  return _buildAnimeCard(context, anime,
                                      isSelected, isRegistered, viewModel);
                                }
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
      floatingActionButton: Consumer<AnimeListViewModel>(
          builder: (context, viewModel, child) {
            final hasSelected = viewModel.selectedAnime.isNotEmpty;

            if (!hasSelected) {
              return const SizedBox.shrink(); // 選択されたアニメがない場合は非表示
            }

            return Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => _handleSaveSelected(context, viewModel),
                backgroundColor: Colors.transparent,
                elevation: 0,
                label: Text(
                  '登録 (${viewModel.selectedAnime.length}件)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                icon: const Icon(
                  Icons.bookmark_add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimeCard(BuildContext context, Map<String, dynamic> anime,
      bool isSelected, bool isRegistered, AnimeListViewModel viewModel) {
    final tid = anime['tid'] ?? 'N/A';

    return AnimeCard(
      anime: anime,
      isSelected: isSelected,
      isRegistered: isRegistered,
      onTap: () {
        // アニメ詳細画面に遷移
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WatchAnimePage(anime: anime),
          ),
        );
      },
      onSelectToggle: !isRegistered
          ? () {
              // 選択状態の切り替え（登録済みでない場合のみ）
              if (isSelected) {
                viewModel.deselectAnime(tid);
              } else {
                viewModel.selectAnime(tid);
              }
            }
          : null,
      onRemove: isRegistered
          ? () async {
              await viewModel.removeAnime(tid);
              // 削除成功のスナックバーを表示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('視聴済みから削除しました'),
                    ],
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          : null,
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

  Future<void> _handleFetchFromServer(
      BuildContext context, AnimeListViewModel viewModel) async {
    try {
      // force: true で強制的に再フェッチ
      await viewModel.fetchFromServer(force: true);
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

  Future<void> _handleSaveSelected(
      BuildContext context, AnimeListViewModel viewModel) async {
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

  Future<bool?> _showUnregisterDialog(BuildContext context,
      AnimeListViewModel viewModel, String tid, String title) async {
    return await showDialog<bool>(
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
                        Colors.red[400]!,
                        Colors.red[600]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.warning_outlined,
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
                  '「$title」を\n登録済みリストから削除しますか？',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'キャンセル',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            // 選択状態にして削除処理を実行
                            viewModel.selectAnime(tid);
                            await viewModel.deleteSelectedAnime();
                            Navigator.of(context).pop(true);
                            AnimeNotification.showSuccess(
                              context,
                              '削除完了',
                              subtitle: '「$title」を登録済みリストから削除しました',
                            );
                          } catch (e) {
                            Navigator.of(context).pop(false);
                            AnimeNotification.showError(
                              context,
                              '削除エラー',
                              subtitle: 'アニメの削除に失敗しました',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          shadowColor: Colors.red.withOpacity(0.3),
                        ),
                        child: Text(
                          '削除',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
}
