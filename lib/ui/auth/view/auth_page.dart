// 遷移先
import 'package:animeishi/ui/auth/view/email_login_page.dart';
import 'package:animeishi/ui/auth/view/email_sign_up_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';

// 標準
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // ログイン・サインインの選択画面

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン・サインアップ'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // メールアドレスでログイン
              ElevatedButton(
                child: const Text('メールアドレスでログイン'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailLoginPage()));
                },
              ),
              // メールアドレスでサインアップ
              ElevatedButton(
                child: const Text('メールアドレスでサインアップ'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailSignUpPage()));
                },
              ),
              // ログアウト
              ElevatedButton(
                child: const Text('ログアウト'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  print('ログアウトしました');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmailLoginPage()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
