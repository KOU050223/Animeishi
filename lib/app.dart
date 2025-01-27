import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:flutter/material.dart';
// import './ui/countUp/view/countUpPage.dart';
import 'package:provider/provider.dart';
import './ui/countUp/view_model/countUp_view_model.dart';
// import './ui/home/view/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CountUpViewModel(),
      child: MaterialApp(
        title: 'アニ名刺',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthPage(),
      ),
    );
  }
}
