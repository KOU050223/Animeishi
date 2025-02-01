import 'package:flutter/material.dart';

class WatchAnimePage extends StatelessWidget {
  final Map<String, dynamic> anime; // WatchListPageから渡されるアニメ情報

  WatchAnimePage({required this.anime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(anime['title']), // アニメのタイトルを表示
      ),
      body: SingleChildScrollView( // スクロール可能にするためにSingleChildScrollViewでラップ
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'タイトル: ${anime['title']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '読み仮名: ${anime['titleyomi']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '放送月: ${anime['firstmonth']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              '放送年: ${anime['firstyear']}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'コメント: ${anime['comment']}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
