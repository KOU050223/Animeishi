import 'package:flutter/material.dart';

class SNSEditPage extends StatefulWidget {
  final String username;
  final List<String> selectedGenres;

  SNSEditPage({required this.username, required this.selectedGenres});

  @override
  _SNSEditPageState createState() => _SNSEditPageState();
}

class _SNSEditPageState extends State<SNSEditPage> {
  late String _username;
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

  @override
  void initState() {
    super.initState();
    _username = widget.username;
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
