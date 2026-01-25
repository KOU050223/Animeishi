import 'package:animeishi/ui/auth/view/auth_page.dart';
import 'package:animeishi/ui/animes/view_model/anime_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // アプリケーション全体でAnimeListViewModelを共有
        ChangeNotifierProvider(
          create: (_) => AnimeListViewModel(),
        ),
      ],
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
