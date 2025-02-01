import 'package:flutter/material.dart';
import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';
import 'package:animeishi/ui/camera/view/camera_page.dart';
import 'package:animeishi/ui/SNS/view/SNS_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    AnimeListPage(),
    CameraPage(),
    SNSPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アニ名刺'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            iconSize: 30,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage()));
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'アニメ'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QRコード'),
          BottomNavigationBarItem(icon: Icon(Icons.social_distance), label: 'SNS'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'プロフィール'),
        ],
        backgroundColor: Colors.blueGrey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('ホーム画面のコンテンツ'));
  }
}
