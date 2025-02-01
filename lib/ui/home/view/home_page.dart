import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/camera/view/qr_page.dart';

class HomePage extends StatelessWidget {
  final String qrData = "https://anime.bang-dream.com/avemujica/"; // テストデータ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('アニ名刺'),
        actions: [
          IconButton(
            icon: Icon(Icons.login),
            onPressed: () {
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
              switch (index) {
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScannerWidget()),
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
