import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPage createState() => _AuthPage();
}

class _AuthPage extends State<AuthPage> {
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
        appBar: AppBar(
          title: const Text('LoginPage'),
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
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Login Error'),
                              content: Text(errorMessage),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      password = '';
                                    });
                                    passwordController.clear();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
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

class BackgroundAnimation1 extends StatefulWidget {
  const BackgroundAnimation1({
    Key? key,
    required this.size,
    required this.child,
  }) : super(key: key);
  final Size size;
  final Widget child;

  @override
  _BackgroundAnimation1State createState() => _BackgroundAnimation1State();
}

class _BackgroundAnimation1State extends State<BackgroundAnimation1> {
  late Timer timer;
  late List<Particle> particles =
      List<Particle>.generate(90, (index) => Particle(size: widget.size));

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 1000 ~/ 60);
    timer = Timer.periodic(duration, (timer) {
      setState(() {
        for (var element in particles) {
          element.moveParticle();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CustomPaint(
          size: size,
          painter: AnimationPainter1(particles),
        ),
        Center(
          child: SizedBox(
            height: size.height * 0.4,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}

class AnimationPainter1 extends CustomPainter {
  List<Particle> particles;
  AnimationPainter1(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var e in particles) {
      canvas.drawCircle(
        e.pos,
        e.radius,
        Paint()
          ..style = PaintingStyle.fill
          ..color = e.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Particle {
  final Color color = getRandomColor();
  final double radius = getRandomVal(1, 5) * 9;

  double dx = getRandomVal(-0.25, 0.25);
  double dy = getRandomVal(-0.25, 0.25);

  late Size size;
  late double x = getRandomVal(0, size.width);
  late double y = getRandomVal(0, size.height);
  late Offset pos = Offset(x, y); // 現在の点の位置

  Particle({required this.size});

  void moveParticle() {
    Offset nextPos = pos + Offset(dx, dy);
    if (nextPos.dx < 0 ||
        size.width < nextPos.dx ||
        nextPos.dy < 0 ||
        size.height < nextPos.dy) {
      dx = -dx;
      dy = -dy;
      nextPos = pos + Offset(dx, dy);
    }
    pos = nextPos;
  }

  static Color getRandomColor() {
    final colorList = [
      Colors.red,
      Colors.blueAccent,
      Colors.orange,
      Colors.yellow,
    ];
    final rnd = Random();
    int index = rnd.nextInt(colorList.length);

    return colorList[index].withOpacity(0.25);
  }

  // min ~ max内のランダムな値を取得
  static double getRandomVal(double min, double max) {
    final rnd = Random();
    return rnd.nextDouble() * (max - min) + min;
  }
}
