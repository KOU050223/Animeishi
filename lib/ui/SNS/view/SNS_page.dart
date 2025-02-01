import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SNSPage extends StatefulWidget {
  @override
  _SNSPageState createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> {
  bool _isLoading = true;
  List<String> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendsList();  // フレンドリストの取得
  }

  // ユーザーのフレンドリストをFirestoreから取得
  Future<void> _fetchFriendsList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;  // 現在ログイン中のユーザーID
      try {
        // Firestoreの「users」コレクション -> 「meishies」サブコレクションからフレンドリストを取得
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('meishies')  // フレンド情報を格納するコレクション
            .get();

        final List<String> friends = snapshot.docs.map((doc) => doc.id).toList();  // フレンドのIDリスト

        setState(() {
          _friendsList = friends;  // フレンドリストを更新
          _isLoading = false;  // ローディング終了
        });
      } catch (e) {
        setState(() {
          _isLoading = false;  // エラー発生時にローディング終了
        });
        print('Failed to fetch friends list: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フレンド一覧'),
        backgroundColor: Color(0xFF66FF99),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // ローディング中
          : _friendsList.isEmpty
              ? Center(child: Text('フレンドがいません'))  // フレンドがいない場合
              : ListView.builder(
                  itemCount: _friendsList.length,
                  itemBuilder: (context, index) {
                    final friendId = _friendsList[index];
                    return ListTile(
                      title: Text(friendId),  // ユーザーIDのみを表示
                      onTap: () {
                        // フレンドをタップしたときの処理（必要なら追加）
                      },
                    );
                  },
                ),
    );
  }
}
