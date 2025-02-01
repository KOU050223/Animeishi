import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditPage extends StatefulWidget {
  final String username;
  final List<String> selectedGenres;
  final String email;

  ProfileEditPage({
    required this.username,
    required this.selectedGenres,
    required this.email,
  });

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late String _username;
  late List<String> _selectedGenres;
  late String _email;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // ユーザーネームのコントローラーを追加

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
    _email = widget.email;
    _emailController.text = _email; // メールアドレスをコントローラーにセット
    _usernameController.text = _username; // ユーザーネームをコントローラーにセット
  }

  // メールアドレスの更新処理
  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // メールアドレスの更新
        if (_emailController.text != _email) {
          await user.updateEmail(_emailController.text);
        }

        // プロフィール保存
        Navigator.pop(context, {
          'username': _usernameController.text, // ユーザーネームもコントローラーから取得
          'selectedGenres': _selectedGenres,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('プロフィールが更新されました')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: プロフィール更新に失敗しました')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('名刺編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('ユーザーネーム', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _usernameController, // ユーザーネームに現在の名前を表示
              onChanged: (value) => _username = value,
              decoration: InputDecoration(hintText: 'ユーザーネームを入力'),
            ),
            SizedBox(height: 20),
            Text('ジャンルを選択', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            Text('メールアドレス', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'メールアドレスを入力'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _username.isEmpty || _emailController.text.isEmpty ? null : _updateProfile,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
