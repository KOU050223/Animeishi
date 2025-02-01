import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/background_animation.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  _EmailLoginPage createState() => _EmailLoginPage();
}

class _EmailLoginPage extends State<EmailLoginPage> {
  String email = '';
  String password = '';
  bool hidePassword = true;
  String errorMessage = '';

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BackgroundAnimation1(
      size: MediaQuery.of(context).size,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.mail),
                  hintText: 'hogehoge@email.com',
                  labelText: 'Email Address',
                ),
                onChanged: (String value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextFormField(
                obscureText: hidePassword,
                decoration: InputDecoration(
                  icon: const Icon(Icons.lock),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                ),
                onChanged: (String value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text('ログイン'),
                onPressed: () async {
                  try {
                    // メール/パスワードでログイン
                    final User? user = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password))
                        .user;
                    if (user != null) {
                      print("ログインしました　${user.email} , ${user.uid}");
                      setState(() {
                        email = '';
                        password = '';
                      });
                      emailController.clear();
                      passwordController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  } catch (e) {
                    // エラーが発生した場合
                    setState(() {
                      errorMessage = 'メールアドレスまたはパスワードが間違っています';
                    });
                    print(e);
                  }
                },
              ),
              // テストログイン用のボタン(!!!!!後で消す!!!!!)
              ElevatedButton(
                child: const Text('テストログイン'),
                onPressed: () async {
                  try {
                    setState(() {
                      // テスト用のメールアドレスとパスワード
                      email = 'test@test.com';
                      password = 'password';
                    });
                    // メール/パスワードでログイン
                    final User? user = (await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password))
                        .user;
                    if (user != null) {
                      print("ログインしました　${user.email} , ${user.uid}");
                      setState(() {
                        email = '';
                        password = '';
                      });
                      emailController.clear();
                      passwordController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    }
                  } catch (e) {
                    // エラーが発生した場合
                    setState(() {
                      errorMessage = 'メールアドレスまたはパスワードが間違っています';
                    });
                    print(e);
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    print("${email}へパスワードリセット用のメールを送信しました");
                  } catch (e) {
                    print(e);
                  }
                },
                child: const Text('パスワードリセット'),
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
    ));
  }
}
