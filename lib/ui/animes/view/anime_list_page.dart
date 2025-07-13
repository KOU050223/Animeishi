import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/anime_list_view_model.dart';
import 'package:animeishi/model/factory/anime_list_factory.dart';
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート

class AnimeListPage extends StatelessWidget {
  const AnimeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = AnimeListViewModel();
        viewModel.fetchFromServer(); // 初期化時にアニメリストと選択されたアニメをロード
        return viewModel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('アニメリスト'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // 戻るボタンを押したときにHomePageに遷移
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()), // HomePageに遷移
              );
            },
          ),
        ),
        body: Consumer<AnimeListViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // ▼ ソート順と昇降ボタンを追加 ▼
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("ソート順: "),
                      DropdownButton<SortOrder>(
                        value: viewModel.sortOrder, // 現在のソート順
                        underline: SizedBox.shrink(), // 下線を非表示
                        onChanged: (SortOrder? newValue) {
                          if (newValue != null) {
                            viewModel.setSortOrder(newValue); // ソート順を変更
                          }
                        },
                        items: [
                          DropdownMenuItem(
                            value: SortOrder.tid,
                            child: Text('TID順'),
                          ),
                          DropdownMenuItem(
                            value: SortOrder.year,
                            child: Text('年代順'),
                          ),
                          DropdownMenuItem(
                            value: SortOrder.name,
                            child: Text('名前順'),
                          ),
                        ],
                      ),
                      // ▼ 昇順・降順ボタン ▼
                      IconButton(
                        icon: Icon(viewModel.isAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward),
                        onPressed: viewModel.toggleSortOrder,
                      ),
                    ],
                  ),
                ),
                // 「オンラインから取得」ボタン
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed:
                        viewModel.isLoading ? null : viewModel.fetchFromServer,
                    icon: viewModel.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_download),
                    label: Text(viewModel.isLoading ? '読み込み中...' : 'オンラインから取得'),
                  ),
                ),
                // 「登録」ボタンと「削除」ボタン
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                try {
                                  await viewModel.deleteSelectedAnime();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('選択したアニメを削除しました'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('削除に失敗しました: $e'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                      ),
                      SizedBox(width: 16), // ボタン間のスペース
                      ElevatedButton.icon(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                try {
                                  await viewModel.saveSelectedAnime();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('選択したアニメを登録しました'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('登録に失敗しました: $e'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.save),
                        label: const Text('登録'),
                      ),
                    ],
                  ),
                ),
                // アニメリスト表示
                Expanded(
                  child: viewModel.animeList.isEmpty
                      ? const Center(child: Text('リストがありません'))
                      : ListView.builder(
                          itemCount: viewModel.animeList.length,
                          itemBuilder: (context, index) {
                            final anime = viewModel.animeList[index];
                            final tid = anime['tid'] ?? 'N/A';
                            final title = anime['title'] ?? 'タイトル不明';
                            final yomi = anime['titleyomi'] ?? '';
                            final firstMonth = anime['firstmonth'] ?? '';
                            final firstYear = anime['firstyear'] ?? '';
                            final comment = anime['comment'] ?? '';

                            return CheckboxListTile(
                              title: Text('$title ($tid)'),
                              subtitle: Text('$firstYear年'
                                  '$firstMonth月'),
                              value: viewModel.selectedAnime.contains(tid),
                              onChanged: (bool? value) {
                                if (value == true) {
                                  viewModel.selectAnime(tid);
                                } else {
                                  viewModel.deselectAnime(tid);
                                }
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
