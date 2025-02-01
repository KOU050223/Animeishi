import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuthをインポート
import 'package:animeishi/ui/SNS/view/friend_watch_list_page.dart'; // FriendWatchListPage のインポート

class SNSPage extends StatefulWidget {
  @override
  _SNSPageState createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> {
  List<String> _friendIds = [];  // フレンドの userId を格納
  List<String> _friendNames = []; // フレンドの名前
  List<List<String>> _friendGenres = []; // フレンドが選んだジャンルのリスト

  String _currentUserId = ''; // 現在のユーザーIDを格納

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // 現在のユーザーIDを取得
    _fetchFriends();
  }

  // 現在のユーザーIDを取得
  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;  // 現在のユーザーIDを保存
      });
    }
  }

  // フレンドリストを取得
  Future<void> _fetchFriends() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      List<String> friendIds = [];
      List<String> friendNames = [];
      List<List<String>> friendGenres = [];

      snapshot.docs.forEach((doc) {
        final userId = doc.id;
        final username = doc['username'] ?? '未設定';  // ユーザーネームがない場合「未設定」
        final genres = List<String>.from(doc['selectedGenres'] ?? []);  // 選択したジャンルを取得

        // 自分のユーザーIDと一致しない場合のみリストに追加
        if (userId != _currentUserId) {
          friendIds.add(userId);
          friendNames.add(username);
          friendGenres.add(genres);
        }
      });

      setState(() {
        _friendIds = friendIds;
        _friendNames = friendNames;
        _friendGenres = friendGenres;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SNSページ')),
      body: ListView.builder(
        itemCount: _friendIds.length,
        itemBuilder: (context, index) {
          final friendId = _friendIds[index];
          final friendName = _friendNames[index];
          final friendGenres = _friendGenres[index];

          return GestureDetector(
            onTap: () {
              // 名刺をタップしたときにフレンドの閲覧履歴ページに遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendWatchListPage(userId: friendId),  // FriendWatchListPageにuserIdを渡す
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,  // 左揃え
                  children: [
                    // ユーザーネームを表示
                    Text(
                      friendName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,  // 長すぎる場合は省略する
                      maxLines: 1,  // 1行に収める
                    ),
                    SizedBox(height: 8.0),
                    
                    // ユーザーIDを表示
                    Text(
                      'ユーザーID: $friendId',
                      style: TextStyle(fontSize: 16),
                      overflow: TextOverflow.ellipsis,  // 長すぎる場合は省略する
                      maxLines: 1,  // 1行に収める
                    ),
                    SizedBox(height: 8.0),

                    // 選択されたジャンルを表示
                    Text(
                      '選択ジャンル: ${friendGenres.isEmpty ? 'なし' : friendGenres.join(', ')}',
                      style: TextStyle(fontSize: 16),
                      softWrap: true,  // テキストが長い場合、自動で改行する
                      overflow: TextOverflow.ellipsis,  // 長すぎる場合は省略する
                    ),
                    SizedBox(height: 16.0),

                    // サブタイトルと視聴履歴ボタン
                    Text(
                      'タップして閲覧履歴を見る',
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    SizedBox(height: 8.0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
