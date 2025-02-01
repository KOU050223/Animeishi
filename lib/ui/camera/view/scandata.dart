import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata;
  const ScanDataWidget({Key? key, this.scandata}) : super(key: key);

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      print('Firestore にアクセスします - userId: $userId');
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data(); // データ取得
        print('ユーザーデータ取得成功: $data');
        return data;
      } else {
        print('ユーザーが Firestore に存在しません - userId: $userId');
      }
    } catch (e) {
      print('Firestore データ取得エラー: $e');
    }
    return null;
  }

  Future<List<String>> getSelectedAnime(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> animeCollection = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .get();

      List<String> animeIds = animeCollection.docs.map((doc) => doc.id).toList();
      print('取得したアニメID: $animeIds');
      return animeIds;
    } catch (e) {
      print('アニメデータ取得時のエラー: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = scandata?.barcodes.first.rawValue ?? 'null';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF99),
        title: const Text('スキャンの結果'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          getUserData(userId), // ユーザー情報
          getSelectedAnime(userId), // アニメ情報
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました'));
          } else if (snapshot.hasData && snapshot.data != null) {
            Map<String, dynamic>? userData = snapshot.data![0] as Map<String, dynamic>?;
            List<String> animeIds = snapshot.data![1] as List<String>;

            if (userData == null) {
              return Center(child: Text('ユーザーデータが見つかりません'));
            }

            String username = userData['username'] ?? '未設定';
            String email = userData['email'] ?? '未設定';
            List<String> selectedGenres = List<String>.from(userData['selectedGenres'] ?? []);

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 左揃え
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ユーザーネーム
                        Row(
                          children: [
                            Text(
                              'ユーザーネーム: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              username,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // 選択されたジャンル
                        Text(
                          '選択されたジャンル:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          selectedGenres.isEmpty ? 'なし' : selectedGenres.join(', '),
                          style: TextStyle(fontSize: 18),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 20),

                        // ユーザーID
                        Row(
                          children: [
                            Text(
                              'ユーザーID: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              userId,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // メールアドレス
                        Row(
                          children: [
                            Text(
                              'メールアドレス: ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              email,
                              style: TextStyle(fontSize: 18),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // アニメリスト
                        Text(
                          '選択されたアニメ:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        animeIds.isEmpty
                            ? Text('なし', style: TextStyle(fontSize: 18))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: animeIds.map((id) => Text('アニメID: $id')).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('データが見つかりません'));
          }
        },
      ),
    );
  }
}
