// 必要なimport文を先頭に移動
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/SNS/view/SNS_edit_page.dart';  // SNSEditPageへのインポート

class SNSPage extends StatefulWidget {
  @override
  _SNSPageState createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> {
  String _username = '';
  List<String> _selectedGenres = [];

  // Firestoreからユーザープロフィールを取得
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userId = user.uid;
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final userData = docSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _username = userData['username'] ?? '';
            _selectedGenres = List<String>.from(userData['selectedGenres'] ?? []);
          });
        }
      } catch (e) {
        print('Failed to load user profile: $e');
      }
    }
  }

  // ユーザープロフィールをFirestoreに保存
  Future<void> _saveUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userId = user.uid;
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'username': _username,
          'selectedGenres': _selectedGenres,
        }, SetOptions(merge: true));  // 上書きせず、マージする
      } catch (e) {
        print('Failed to save user profile: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();  // アプリ起動時にFirestoreからユーザープロフィールをロード
  }

  // プロフィールを更新
  void updateProfile(String username, List<String> selectedGenres) {
    setState(() {
      _username = username;
      _selectedGenres = selectedGenres.isEmpty ? ['なし'] : selectedGenres; // 変更：選択されていない場合「なし」を自動選択
    });
    _saveUserProfile();  // プロフィールをFirestoreに保存
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('名刺')),
      body: Center(
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ユーザーネーム:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _username.isEmpty ? '未設定' : _username, // 空の場合は「未設定」を表示
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text(
                  '選択されたジャンル:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  _selectedGenres.isEmpty ? 'なし' : _selectedGenres.join(', '),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SNSEditPage(
                          username: _username,
                          selectedGenres: _selectedGenres,
                        ),
                      ),
                    );
                    if (result != null) {
                      updateProfile(result['username'], result['selectedGenres']);
                    }
                  },
                  child: Text('名刺を編集'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
