import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata;
  const ScanDataWidget({Key? key, this.scandata}) : super(key: key);

  /// ユーザーデータを取得する
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      print('ユーザーデータ取得: $userId');
      print(doc);
      if (doc.exists) {
        return doc.data();
      } else {
        print('ユーザーが存在しません: $userId');
      }
    } catch (e) {
      print('ユーザーデータ取得エラー: $e');
    }
    return null;
  }

  /// ユーザーが選択したアニメの TID を取得する
  Future<Set<String>> getSelectedAnimeTIDs(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .get();

      // 各ドキュメントのIDが TID として登録されていると仮定
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      print('selectedAnime 取得エラー: $e');
      return {};
    }
  }

  /// 取得した TID に基づいて、アニメ詳細情報（ここではアニメ名）を取得する
  Future<List<Map<String, dynamic>>> getAnimeDetails(Set<String> tids) async {
    List<Map<String, dynamic>> animeList = [];
    try {
      // "titles" コレクションから全件取得（件数が多い場合は where クエリなどで絞ることを検討）
      final snapshot =
          await FirebaseFirestore.instance.collection('titles').get();
      for (var doc in snapshot.docs) {
        if (tids.contains(doc.id)) {
          // 'Title' フィールドにアニメの名前が入っていると仮定
          animeList.add({
            'tid': doc.id,
            'title': doc.data()['Title'] ?? 'タイトル未設定',
          });
        }
      }
    } catch (e) {
      print('アニメ詳細取得エラー: $e');
    }
    return animeList;
  }

  /// ユーザーデータとアニメ詳細情報の両方を取得する
  Future<List<dynamic>> fetchData(String userId) async {
    final userData = await getUserData(userId);
    final tids = await getSelectedAnimeTIDs(userId);
    final animeDetails = await getAnimeDetails(tids);
    return [userData, animeDetails];
  }

  @override
  Widget build(BuildContext context) {
    // scandata から userId を取得（なければ 'null' を指定）
    final userId = scandata?.barcodes.first.rawValue ?? 'null';
    print('QR取得後の' + userId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF99),
        title: const Text('スキャンの結果'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('エラーが発生しました'));
          } else if (snapshot.hasData) {
            // snapshot.data[0] はユーザーデータ、[1] はアニメの詳細リスト
            final Map<String, dynamic>? userData =
                snapshot.data![0] as Map<String, dynamic>?;
            final List<Map<String, dynamic>> animeList =
                snapshot.data![1] as List<Map<String, dynamic>>;

            if (userData == null) {
              return const Center(child: Text('ユーザーデータが見つかりません'));
            }

            List<String> selectedGenres =
                List<String>.from(userData['selectedGenres'] ?? []);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ユーザー情報の表示
                  Text(
                    'ユーザーネーム: ${userData['username'] ?? '未設定'}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // 選択されたジャンル
                  const Text(
                    '選択されたジャンル:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    selectedGenres.isEmpty ? 'なし' : selectedGenres.join(', '),
                    style: const TextStyle(fontSize: 18),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '視聴履歴:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // アニメ詳細のリスト表示
                  Expanded(
                    child: animeList.isEmpty
                        ? const Text('視聴履歴はありません')
                        : ListView.builder(
                            itemCount: animeList.length,
                            itemBuilder: (context, index) {
                              final anime = animeList[index];
                              return ListTile(
                                title: Text(anime['title']),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('データが見つかりません'));
          }
        },
      ),
    );
  }
}
