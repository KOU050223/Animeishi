// 標準
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

// 各画面のインポート（プロジェクト内のパスに合わせて調整してください）
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/animes/view/anime_list_page.dart';
import 'package:animeishi/ui/profile/view/profile_page.dart';
import 'package:animeishi/ui/camera/view/qr_page.dart'; // ここにScannerWidgetが含まれている前提
import 'package:animeishi/ui/SNS/view/SNS_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 各ページのウィジェットリスト
  final List<Widget> _pages = [
    // ホーム画面はHomePageContentで、qrDataはbuild内で渡します
    // そのため、ここでは仮のWidgetとしてnullを入れ、
    // インデックス0のときだけHomePageContentを直接表示する形にしています。
    Container(),
    AnimeListPage(),
    ScannerWidget(), // QRコードスキャン画面。CameraPageの場合は適宜変更してください。
    SNSPage(),
    ProfilePage(),
  ];

  // FirebaseAuthから現在のユーザーを取得
  final User? user = FirebaseAuth.instance.currentUser;

  // ユーザーUID（ログインしていなければ "No UID"）
  String get qrData => user?.uid ?? "No UID";

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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            },
          ),
        ],
      ),
      // インデックス0ならHomePageContent（QRコード表示）、それ以外ならリストから取得
      body: _currentIndex == 0
          ? HomePageContent(qrData: qrData)
          : _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'アニメ'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QRコード'),
          BottomNavigationBarItem(
              icon: Icon(Icons.social_distance), label: 'SNS'),
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
  const HomePageContent({Key? key, required this.qrData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'あなたの名刺QRコード',
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
