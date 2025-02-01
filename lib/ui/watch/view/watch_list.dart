import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/watch/view/watch_anime.dart';


class WatchListPage extends StatefulWidget {
  @override
  _WatchListPageState createState() => _WatchListPageState();
}

class _WatchListPageState extends State<WatchListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _animeList = [];
  Set<String> _selectedAnime = {}; // ユーザーが選択したアニメのTIDを保持

  @override
  void initState() {
    super.initState();
    _fetchSelectedAnime();
  }

  // ユーザーの選択されたアニメ(TID)をFirestoreから取得する
  Future<void> _fetchSelectedAnime() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selectedAnime')
            .get();

        _selectedAnime = snapshot.docs.map((doc) => doc.id).toSet();
        await _fetchAnimeDetails();
      } catch (e) {
        print('Failed to fetch selected anime: $e');
      }
    }
  }

  // 選択されたTIDに基づいてアニメの詳細を取得
  Future<void> _fetchAnimeDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('titles')
          .get();

      final List<Map<String, dynamic>> fetchedList = snapshot.docs
          .where((doc) => _selectedAnime.contains(doc.id))  // 選択されたTIDのものだけフィルタリング
          .map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'].toString(),
          'title': doc['Title'],
        };
      }).toList();

      setState(() {
        _animeList = fetchedList;  // フィルタリングしたアニメのリストをセット
        _isLoading = false;  // ローディング終了
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to fetch anime details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('視聴履歴'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // ローディング中
          : _animeList.isEmpty
              ? Center(child: Text('視聴履歴はありません'))  // データがない場合
              : ListView.builder(
                  itemCount: _animeList.length,
                  itemBuilder: (context, index) {
                    final anime = _animeList[index];
                    return ListTile(
                      title: Text(anime['title']),  // アニメのタイトルのみを表示
                      onTap: () {
                        // アニメ名をタップしたときに詳細ページへ遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WatchAnimePage(anime: anime),  // anime情報を渡して詳細ページへ
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
