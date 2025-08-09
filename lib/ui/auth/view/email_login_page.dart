import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/ui/auth/components/email_login_validation.dart';
import 'package:animeishi/ui/auth/components/email_login_dialogs.dart';
import 'package:animeishi/config/feature_flags.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({Key? key}) : super(key: key);

  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool hidePassword = true;
  String errorMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailError = EmailLoginValidation.validateEmail(emailController.text);
    final passwordError = EmailLoginValidation.validatePassword(passwordController.text);
    
    if (emailError != null || passwordError != null) {
      EmailLoginDialogs.showValidationDialog(context, emailError, passwordError);
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final User? user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailController.text.trim(), 
              password: passwordController.text))
          .user;

      if (user != null) {
        if (FeatureFlags.enableDebugLogs) {
          print("ログインしました ${user.email}, ${user.uid}");
        }
        
        EmailLoginDialogs.showSuccessMessage(context);
        
        await Future.delayed(Duration(milliseconds: 1500));
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      if (FeatureFlags.enableDebugLogs) {
        print('ログインエラー: $e');
      }
      
      setState(() {
        errorMessage = EmailLoginValidation.getFirebaseErrorMessage(e.toString());
      });
      
      EmailLoginDialogs.showErrorDialog(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _testLogin() async {
    emailController.text = 'test@test.com';
    passwordController.text = 'password';
    await _login();
  }

  Future<void> _resetPassword() async {
    final emailError = EmailLoginValidation.validateEmail(emailController.text);
    
    if (emailError != null) {
      EmailLoginDialogs.showValidationDialog(context, emailError, null);
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      
      EmailLoginDialogs.showInfoDialog(
        context,
        'パスワードリセット',
        '${emailController.text}へパスワードリセット用のメールを送信しました',
        Icons.email_outlined,
        Colors.blue,
      );
    } catch (e) {
      EmailLoginDialogs.showErrorDialog(context, 'パスワードリセットメールの送信に失敗しました');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.mail, color: Colors.white),
                    hintText: 'hogehoge@email.com',
                    labelText: 'Email Address',
                    labelStyle: TextStyle(color: Colors.white),
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock, color: Colors.white),
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('ログイン'),
                  onPressed: isLoading ? null : _login,
                ),
                const SizedBox(height: 10),
                if (FeatureFlags.enableTestLogin) 
                  ElevatedButton(
                    onPressed: isLoading ? null : _testLogin,
                    child: const Text('テストログイン'),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isLoading ? null : _resetPassword,
                  child: const Text('パスワードリセット'),
                ),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
