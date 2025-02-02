import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/background_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountSettingPage extends StatefulWidget {
  const AccountSettingPage({Key? key}) : super(key: key);

  @override
  _AccountSettingState createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSettingPage> {
  String email = '';
  String password = '';
  String userName = '';

  bool hidePassword = true;
  String errorMessage = '';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updateUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateProfile(displayName: userName);
        await user.reload();
        // Firestoreにユーザードキュメントを作成
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'username': userName,
          'selectedGenres': [],
        });
        print('ユーザー名が更新されました: ${userName}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        print('ユーザー名の更新中にエラーが発生しました: $e');
      }
    } else {
      print('ユーザーがログインしていません');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント設定'),
      ),
      body: BackgroundAnimation1(
        size: MediaQuery.of(context).size,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'アカウント設定',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.supervised_user_circle),
                    hintText: 'ユーザー名を入力してください',
                    labelText: 'User Name',
                  ),
                  onChanged: (String value) {
                    setState(() {
                      userName = value;
                    });
                    print(userName);
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  child: const Text('登録'),
                  onPressed: _updateUsername,
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
