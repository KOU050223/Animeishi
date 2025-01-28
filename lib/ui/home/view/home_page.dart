// 遷移先
import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';

// 標準
import 'package:flutter/material.dart';

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
                  context, MaterialPageRoute(builder: (context) => AuthPage()));
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
                label: 'アニメ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code),
                label: 'QRコード',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.social_distance),
                label: 'SNS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'プロフィール',
              ),
            ],
            backgroundColor: Colors.blueGrey,
            onTap: (index) {
              // 各ボタンを押したときの処理をここに書く
              switch (index) {
                case 0: //ホーム画面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                  break;
                case 1: //アニメ画面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnimeListPage()),
                  );
                  break;
                case 4: //プロフィール画面
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                  break;
                default:
              }
            },
          ),
        ],
      ),
    );
  }
}
