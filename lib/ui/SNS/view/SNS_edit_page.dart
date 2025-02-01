import 'package:flutter/material.dart';
import 'package:animeishi/ui/SNS/view/SNS_page.dart';

class SNSEditPage extends StatefulWidget {
  final String username;
  final Color backgroundColor;
  final Color textColor;
  final List<String> selectedGenres;

  SNSEditPage({required this.username, required this.backgroundColor, required this.textColor, required this.selectedGenres});

  @override
  _SNSEditPageState createState() => _SNSEditPageState();
}

class _SNSEditPageState extends State<SNSEditPage> {
  late String _username;
  late Color _backgroundColor;
  late Color _textColor;
  late List<String> _selectedGenres;

  final List<String> _allGenres = [
    'SF/ファンタジー',
    'ロボット/メカ',
    'アクション/バトル',
    'コメディ/ギャグ',
    '恋愛/ラブコメ',
    '日常/ほのぼの',
    'スポーツ/競技',
    'ホラー/サスペンス/推理',
    '歴史/戦記',
    '戦争/ミリタリー',
    'ドラマ/青春',
    'キッズ/ファミリー',
    'ショート',
    '2.5次元舞台',
    'ライブ/ラジオ/etc',
  ];

  final List<Color> _backgroundColors = [
    Colors.white,
    Colors.blueGrey,
    Colors.lightGreen,
    Colors.yellow,
    Colors.pink,
    Colors.orange,
    Colors.indigo,
    Colors.purple,
  ];

  final List<Color> _textColors = [
    Colors.blue,
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _backgroundColor = widget.backgroundColor;
    _textColor = widget.textColor;
    _selectedGenres = List.from(widget.selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('名刺編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('ユーザーネーム', style: TextStyle(fontSize: 18)),
            TextField(
              onChanged: (value) => _username = value,
              decoration: InputDecoration(
                hintText: 'ユーザーネームを入力',
                errorText: _username.isEmpty ? 'ユーザーネームは必須です' : null,
              ),
            ),
            SizedBox(height: 20),
            Text('背景色を選択', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8.0,
              children: _backgroundColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _backgroundColor = color;
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: color,
                    margin: EdgeInsets.all(5),
                    child: _backgroundColor == color
                        ? Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('文字色を選択', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8.0,
              children: _textColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _textColor = color;
                  }),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: color,
                    margin: EdgeInsets.all(5),
                    child: _textColor == color
                        ? Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('ジャンルを選択', style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8.0,
              children: _allGenres.map((genre) {
                return FilterChip(
                  label: Text(genre),
                  selected: _selectedGenres.contains(genre),
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _username.isEmpty
                  ? null
                  : () {
                      if (_selectedGenres.isEmpty) {
                        _selectedGenres.add('なし');  // ジャンルが選択されていない場合に「なし」を追加
                      }
                      Navigator.pop(context, {
                        'username': _username,
                        'backgroundColor': _backgroundColor,
                        'textColor': _textColor,
                        'selectedGenres': _selectedGenres,
                      });
                    },
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
