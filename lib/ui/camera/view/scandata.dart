import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata;
  const ScanDataWidget({Key? key, this.scandata}) : super(key: key);

Future<Map<String, dynamic>?> getUserData(String userId) async {
  try {
    print('Firestore にアクセスします - userId: $userId');
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data(); // データ取得
      print('ユーザーデータ取得成功: $data');
      return data;
    } else {
      print('ユーザーが Firestore に存在しません - userId: $userId');
    }
  } catch (e) {
    print('Firestore データ取得エラー: $e');
  }
  return null;
}
Future<List<String>> getSelectedAnime(String userId) async {
  try {
    QuerySnapshot<Map<String, dynamic>> animeCollection = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('selectedAnime')
        .get();

    List<String> animeIds = animeCollection.docs.map((doc) => doc.id).toList();
    print('取得したアニメID: $animeIds');
    return animeIds;
  } catch (e) {
    print('アニメデータ取得時のエラー: $e');
    return [];
  }
}

@override
Widget build(BuildContext context) {
  String userId = scandata?.barcodes.first.rawValue ?? 'null';

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF66FF99),
      title: const Text('スキャンの結果'),
    ),
    body: FutureBuilder<List<dynamic>>(
      future: Future.wait([
        getUserData(userId), // ユーザー情報
        getSelectedAnime(userId), // アニメ情報
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        } else if (snapshot.hasData && snapshot.data != null) {
          Map<String, dynamic>? userData = snapshot.data![0] as Map<String, dynamic>?;
          List<String> animeIds = snapshot.data![1] as List<String>;

          return ListView(
            children: [
              Card(
                color: const Color(0xFFFFEECC),
                elevation: 5,
                margin: const EdgeInsets.all(9),
                child: ListTile(
                  title: Text(
                    '選択されたアニメ',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: animeIds.map((id) => Text('アニメID: $id')).toList(),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Center(child: Text('データが見つかりません'));
        }
      },
    ),
  );
 }
}
