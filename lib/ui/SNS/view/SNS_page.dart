import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/SNS/view/friend_watch_list_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート（ここが重要）

class SNSPage extends StatefulWidget {
  const SNSPage({super.key});

  @override
  State<SNSPage> createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> {
  List<String> _friendIds = [];
  List<String> _friendNames = [];
  List<List<String>> _friendGenres = [];

  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _fetchFriends();
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  Future<void> _fetchFriends() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('meishies')
          .get();

      List<String> friendIds = [];
      List<String> friendNames = [];
      List<List<String>> friendGenres = [];

      for (var doc in userDoc.docs) {
        final friendId = doc.id;
        final friendDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendDoc.exists) {
          final friendName = friendDoc['username'] ?? '未設定';
          final genres = List<String>.from(friendDoc['selectedGenres'] ?? []);

          friendIds.add(friendId);
          friendNames.add(friendName);
          friendGenres.add(genres);
        }
      }

      setState(() {
        _friendIds = friendIds;
        _friendNames = friendNames;
        _friendGenres = friendGenres;
      });
    } catch (e) {
      print('Failed to fetch friends: $e');
    }
  }

  Future<void> _deleteFriend(String friendId) async {
    try {
      // Firestore からフレンドを削除
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('meishies')
          .doc(friendId)
          .delete();

      // ローカルリストから削除
      setState(() {
        final index = _friendIds.indexOf(friendId);
        _friendIds.removeAt(index);
        _friendNames.removeAt(index);
        _friendGenres.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('フレンドを削除しました')),
      );
    } catch (e) {
      print('Failed to delete friend: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('削除に失敗しました')),
      );
    }
  }

  void _showDeleteConfirmationDialog(String friendId, String friendName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('削除確認'),
        content: Text('$friendName を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // キャンセル
            child: Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              _deleteFriend(friendId); // フレンド削除
            },
            child: Text('削除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フレンドリスト/名刺一覧'),
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
      body: ListView.builder(
        itemCount: _friendIds.length,
        itemBuilder: (context, index) {
          final friendId = _friendIds[index];
          final friendName = _friendNames[index];
          final friendGenres = _friendGenres[index];

          return Card(
            margin: EdgeInsets.all(8.0),
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'ユーザーID: $friendId',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '選択ジャンル: ${friendGenres.isEmpty ? 'なし' : friendGenres.join(', ')}',
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FriendWatchListPage(userId: friendId),
                            ),
                          );
                        },
                        child: Text(
                          '閲覧履歴を見る',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(friendId, friendName),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
