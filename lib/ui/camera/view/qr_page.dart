import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/camera/view/scandata.dart';
import 'package:animeishi/ui/home/view/home_page.dart'; // HomePage のインポート

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();

  /// **Firestore にスキャン情報を保存する**
  Future<void> saveUserIdToFirestore(String scannedUserId) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print("エラー: ログインしていません");
        return;
      }

      String currentUserId = currentUser.uid; // 現在ログインしているユーザーID

      // 自分のリストに相手を保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId) // 現在ログインしているユーザーの Firestore ドキュメント
          .collection('meishies')
          .doc(scannedUserId) // 読み取ったユーザーの ID をドキュメント ID に
          .set({
        'scanned_at': FieldValue.serverTimestamp(), // スキャンした日時
      });

      // 相手のリストに自分を保存
      await FirebaseFirestore.instance
          .collection('users')
          .doc(scannedUserId) // 現在ログインしているユーザーの Firestore ドキュメント
          .collection('meishies')
          .doc(currentUserId) // 読み取ったユーザーの ID をドキュメント ID に
          .set({
        'scanned_at': FieldValue.serverTimestamp(), // スキャンした日時
      });

      print("ユーザーID $scannedUserId を Firestore に保存しました");
    } catch (e) {
      print("Firestore への保存に失敗しました: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF99),
        title: const Text('スキャンしよう'),
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
      backgroundColor: Colors.black,
      body: MobileScanner(
        controller: controller,
        fit: BoxFit.contain,
        onDetect: (scandata) {
          final scannedUserId = scandata.barcodes.first.rawValue;
          print('スキャン結果: $scannedUserId');
          if (scannedUserId != null && scannedUserId.isNotEmpty) {
            setState(() {
              controller.stop(); // スキャン成功後にカメラを停止
              saveUserIdToFirestore(scannedUserId); // **Firestore に保存**
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return ScanDataWidget(scandata: scandata);
                  },
                ),
              );
            });
          }
        },
      ),
    );
  }
}
