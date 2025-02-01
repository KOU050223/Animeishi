import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'watch_anime.dart'; // watch_anime.dartをインポート

class WatchListPage extends StatefulWidget {
  @override
  _WatchListPageState createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _animeList = [];

  @override
  void initState() {
    super.initState();
    _fetchAnimeList();
  }

  // Firestoreからアニメのリストを取得するメソッド
  Future<void> _fetchAnimeList() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('titles') // Firestoreの'titles'コレクションからデータを取得
          .get();

      final List<Map<String, dynamic>> fetchedList = querySnapshot.docs.map((doc) {
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

      setState(() {
        _animeList = fetchedList; // データをリストにセット
        _isLoading = false; // ローディングを終了
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch anime list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('視聴履歴'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // ローディング中
          : _animeList.isEmpty
              ? Center(child: Text('視聴履歴はありません')) // アニメがない場合
              : ListView.builder(
                  itemCount: _animeList.length,
                  itemBuilder: (context, index) {
                    final anime = _animeList[index];
                    return ListTile(
                      title: Text(anime['title']), // アニメの名前を表示
                      onTap: () {
                        // アニメ名をタップしたときに詳細ページへ遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WatchAnimePage(anime: anime), // animeを渡して詳細ページへ
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
