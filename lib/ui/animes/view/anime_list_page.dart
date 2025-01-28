import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeListPage extends StatefulWidget {
  const AnimeListPage({Key? key}) : super(key: key);

  @override
  State<AnimeListPage> createState() => _AnimeListPageState();
}

class _AnimeListPageState extends State<AnimeListPage> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _animeList = []; // 表示用リスト

  @override
  void initState() {
    super.initState();
    // 1. 起動時はローカルモードにして、キャッシュがあればそれを取得
    _initOfflineModeAndLoadCache();
  }

  Future<void> _initOfflineModeAndLoadCache() async {
    await FirebaseFirestore.instance.disableNetwork();
    // ローカルキャッシュから読み取る
    final cacheSnapshot = await FirebaseFirestore.instance
        .collection('titles')
        .get(const GetOptions(source: Source.cache))
        .catchError((e) {
      debugPrint('Error reading cache: $e');
      return null;
    });

    if (cacheSnapshot != null) {
      final List<Map<String, dynamic>> cacheList =
          cacheSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'],
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      // ▼ ここでローカルのリストをソートする ▼
      // たとえば 'tid' を文字列として昇順ソートする場合:
      // cacheList.sort((a, b) {
      //   final aTid = a['tid'] as String;
      //   final bTid = b['tid'] as String;
      //   return aTid.compareTo(bTid); // 文字列比較
      // });

      // 数値としてソートしたい場合は、int.parse() 等を使ってください
      cacheList.sort((a, b) {
        final aTid = int.tryParse(a['tid'].toString()) ?? 0;
        final bTid = int.tryParse(b['tid'].toString()) ?? 0;
        return bTid.compareTo(aTid); // 数値昇順
      });

      setState(() {
        _animeList = cacheList;
      });
    }
  }

  // 「オンラインから最新を取得」ボタンの処理
  Future<void> _fetchFromServer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1) ネットワーク有効化
      await FirebaseFirestore.instance.enableNetwork();

      // 2) サーバーから一括取得 (get)
      final serverSnapshot = await FirebaseFirestore.instance
          .collection('titles')
          .get(const GetOptions(source: Source.server));

      // 3) _animeList を更新
      final List<Map<String, dynamic>> newList = serverSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'], // フィールド名を "Tid" に合わせる
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      setState(() {
        _animeList = newList;
      });

      // 4) 取得後、必要ならオフラインに戻す
      await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      debugPrint('Error fetching from server: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 画面描画
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アニメリスト'),
      ),
      body: Column(
        children: [
          // 「オンラインから取得」ボタン
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchFromServer,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download),
              label: Text(_isLoading ? '読み込み中...' : 'オンラインから取得'),
            ),
          ),

          // アニメリスト表示
          Expanded(
            child: _animeList.isEmpty
                ? const Center(child: Text('リストがありません'))
                : ListView.builder(
                    itemCount: _animeList.length,
                    itemBuilder: (context, index) {
                      final anime = _animeList[index];
                      final tid = anime['tid'] ?? 'N/A';
                      final title = anime['title'] ?? 'タイトル不明';
                      final yomi = anime['titleyomi'] ?? '';
                      final firstMonth = anime['firstmonth'] ?? '';
                      final firstYear = anime['firstyear'] ?? '';
                      final comment = anime['comment'] ?? '';

                      return ListTile(
                        title: Text('$title (Tid: $tid)'),
                        subtitle: Text('$firstYear年'
                            '$firstMonth月'
                            // 'Comment: $comment',
                            ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
