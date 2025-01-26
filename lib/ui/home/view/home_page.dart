import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アニ名刺'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
              // 認証ページに遷移する処理をここに書く
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AuthGate()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('ホーム画面のコンテンツ'),
            ),
          ),
          BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '検索',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: '通知',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'メッセージ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'プロフィール',
              ),
            ],
            onTap: (index) {
              // 各ボタンを押したときの処理をここに書く
            },
          ),
        ],
      ),
    );
  }
}
