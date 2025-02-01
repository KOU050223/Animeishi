import 'package:flutter/material.dart';
import 'package:animeishi/ui/SNS/view/SNS_edit_page.dart';

class SNSPage extends StatefulWidget {
  @override
  _SNSPageState createState() => _SNSPageState();
}

class _SNSPageState extends State<SNSPage> {
  String _username = 'ユーザー名';
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.blue;
  List<String> _selectedGenres = [];  // 変更：初期状態で「なし」を選択しない

  void updateProfile(String username, Color backgroundColor, Color textColor, List<String> selectedGenres) {
    setState(() {
      _username = username;
      _backgroundColor = backgroundColor;
      _textColor = textColor;
      _selectedGenres = selectedGenres.isEmpty ? ['なし'] : selectedGenres;  // 変更：選択されていない場合「なし」を自動選択
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('名刺')),
      body: Center(
        child: Card(
          color: _backgroundColor,
          elevation: 5,
          margin: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ユーザーネーム:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 10),
                Text(
                  _username,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 20),
                Text(
                  '選択されたジャンル:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 10),
                Text(
                  _selectedGenres.isEmpty ? 'なし' : _selectedGenres.join(', '),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SNSEditPage(
                          username: _username,
                          backgroundColor: _backgroundColor,
                          textColor: _textColor,
                          selectedGenres: _selectedGenres,
                        ),
                      ),
                    );
                    if (result != null) {
                      updateProfile(result['username'], result['backgroundColor'], result['textColor'], result['selectedGenres']);
                    }
                  },
                  child: Text('名刺を編集'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
