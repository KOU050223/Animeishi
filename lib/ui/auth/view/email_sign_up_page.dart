import 'package:animeishi/ui/auth/view/account_setting_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../components/background_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailSignUpPage extends StatefulWidget {
  const EmailSignUpPage({Key? key}) : super(key: key);

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUpPage> {
  // 入力したメールアドレス・パスワード
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

  Future<void> createUserDocument(String userId) async {
    try {
      // // Firestoreにユーザードキュメントを作成
      // await FirebaseFirestore.instance.collection('users').doc(userId).set({
      //   'email': email,
      //   'createdAt': FieldValue.serverTimestamp(),
      //   'username': '',
      // });
      // Firestoreにユーザードキュメントを作成
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'username': '',
        'selectedGenres': [],
      });

      // 空の`selectedAnime`コレクションを作成
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .doc('0')
          .set({});

      // 空の`meishies`コレクションを作成
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meishies')
          .doc('Tr02PKzArJexjIRw4bWjBxseENH3')
          .set({});

      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .collection('meishies')
      //     .doc('dummy')
      //     .delete();

      print('ユーザードキュメントとコレクションを作成しました');
    } catch (e) {
      print('ユーザードキュメントの作成中にエラーが発生しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ログイン'),
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
                    'Sign Up',
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
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                    child: const Text('登録'),
                    onPressed: () async {
                      try {
                        final User? user = (await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: email, password: password))
                            .user;
                        if (user != null) {
                          print("ユーザ登録しました ${user.email} , ${user.uid}");
                          await createUserDocument(user.uid);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountSettingPage()));
                        }
                      } catch (e) {
                        // エラーが発生した場合
                        setState(() {
                          errorMessage = e.toString();
                        });
                        print(e);
                      }
                    },
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
