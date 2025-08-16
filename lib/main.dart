import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env'); // ← 追加: .envの読み込み
  } catch (e) {
    print('Warning: .env file not found or could not be loaded: $e');
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 縦画面固定を設定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // 通常の縦画面
    DeviceOrientation.portraitDown, // 逆さまの縦画面（必要に応じて省略可能）
  ]);
  // Firestoreエミュレータに接続
  // FirebaseFirestore.instance.settings = const Settings(
  //   host: 'localhost:8080',
  //   sslEnabled: false,
  //   persistenceEnabled: false,
  // );
  runApp(const MyApp());
}
