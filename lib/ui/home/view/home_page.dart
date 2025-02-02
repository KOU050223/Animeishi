import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';
import 'package:animeishi/ui/camera/view/qr_page.dart';
import 'package:animeishi/ui/SNS/view/SNS_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 各ページのウィジェットリスト
  final List<Widget> _pages = [
    Container(),  // ホーム画面のため仮のContainer
    AnimeListPage(),
    ScannerWidget(), // QRコードスキャン画面
    SNSPage(),
    ProfilePage(),
  ];

  final User? _user = FirebaseAuth.instance.currentUser;
  String get qrData => _user?.uid ?? "No UID";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,  // AppBar を削除します
      body: _currentIndex == 0
          ? HomePageContent(qrData: qrData, user: _user)
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'アニメ'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QRコード'),
          BottomNavigationBarItem(icon: Icon(Icons.social_distance), label: 'フレンド'),
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
  final String qrData;
  final User? user;

  const HomePageContent({Key? key, required this.qrData, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${user?.displayName ?? 'あなた'}の名刺QRコード',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.0,
          ),
          SizedBox(height: 20),
          Text(
            'このQRコードをスキャンして\nあなたの情報を共有しよう！',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
