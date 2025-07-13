import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreをインポート
import 'package:animeishi/ui/profile/view/profile_edit_page.dart'; // ProfileEditPage のインポート
import 'package:animeishi/ui/watch/view/watch_list.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart'; // AuthPage のインポート
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート（ここが重要）

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _userId = '';
  String _email = '';
  List<String> _selectedGenres = [];

  // Firestoreからユーザープロフィールを取得
  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userId = user.uid;
        setState(() {
          _userId = user.uid;
          _email = user.email ?? '';
          _username = user.displayName ?? '';
        });

        // Firestoreからユーザー情報を取得
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _selectedGenres =
                List<String>.from(userDoc['selectedGenres'] ?? []); // ジャンルを取得
          });
        }
      } catch (e) {
        print('Failed to load user profile: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // ユーザーのプロファイルを取得
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール/名刺'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 「戻る」ボタンでHomePageに戻る
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // HomePageに遷移
            );
          },
        ),
      ),
      body: Center(
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
                  // ユーザーネームを同じ行に表示
                  Row(
                    children: [
                      Text(
                        'ユーザーネーム: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _username.isEmpty ? '未設定' : _username,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // 選択されたジャンルを改行して表示
                  Text(
                    '選択されたジャンル:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _selectedGenres.isEmpty ? 'なし' : _selectedGenres.join(', '),
                    style: TextStyle(fontSize: 18),
                    softWrap: true, // 自動的に改行される
                    overflow: TextOverflow.ellipsis, // 文字が長すぎる場合、省略符号で表示
                  ),
                  SizedBox(height: 20),

                  // ユーザーIDを同じ行に表示
                  Row(
                    children: [
                      Text(
                        'ユーザーID: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          _userId.isEmpty ? '未設定' : _userId,
                          style: TextStyle(fontSize: 16),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // メールアドレスを同じ行に表示
                  Row(
                    children: [
                      Text(
                        'メールアドレス: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                        _email.isEmpty ? '未設定' : _email,
                        style: TextStyle(fontSize: 16),
                        softWrap: true, // 自動的に改行される
                        overflow: TextOverflow.ellipsis, // 文字が長すぎる場合、省略符号で表示
                      ),
                     ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // プロフィール編集ボタン
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileEditPage(
                            username: _username,
                            selectedGenres: _selectedGenres,
                            email: _email, // パスワードは渡さない
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _username = result['username'];
                          _selectedGenres = result['selectedGenres'];
                          _email = result['email'];
                        });
                      }
                    },
                    child: Text('プロフィールを編集'),
                  ),

                  // 視聴履歴ボタン
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // 「視聴履歴」ボタンを押したら WatchListPage に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WatchListPage()),
                      );
                    },
                    child: Text('視聴履歴'),
                  ),

                  // ログイン画面に遷移するボタン
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // ログイン画面に遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuthPage(), // ログインページへの遷移
                        ),
                      );
                    },
                    child: Text('ログイン画面に移動'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
