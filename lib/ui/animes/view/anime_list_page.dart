import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/anime_list_view_model.dart';
import 'package:animeishi/model/factory/anime_list_factory.dart';

class AnimeListPage extends StatelessWidget {
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
          title: Text('Anime List'),
        ),
        body: Consumer<AnimeListViewModel>(
          builder: (context, viewModel, child) {
            return Column(
              children: [
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
                ElevatedButton.icon(
                  onPressed:
                      viewModel.isLoading ? null : () => AnimeListFactory(),
                  icon: viewModel.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download),
                  label: Text(viewModel.isLoading ? '読み込み中...' : 'テストデータを生成'),
                ),
                // 「登録」ボタン
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : viewModel.saveSelectedAnime,
                    icon: const Icon(Icons.save),
                    label: const Text('登録'),
                  ),
                ),
                // 「削除」ボタン
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isLoading
                        ? null
                        : viewModel.deleteSelectedAnime,
                    icon: const Icon(Icons.delete),
                    label: const Text('削除'),
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
