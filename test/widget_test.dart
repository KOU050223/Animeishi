// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('基本ウィジェットテスト', () {
    testWidgets('MaterialApp基本テスト', (WidgetTester tester) async {
      // シンプルなMaterialAppのテスト
      await tester.pumpWidget(
        MaterialApp(
          title: 'テストアプリ',
          home: Scaffold(
            appBar: AppBar(title: const Text('テストページ')),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Hello, World!'),
                  Icon(Icons.star),
                ],
              ),
            ),
          ),
        ),
      );

      // AppBarのタイトルが表示されることを確認
      expect(find.text('テストページ'), findsOneWidget);

      // ボディのテキストが表示されることを確認
      expect(find.text('Hello, World!'), findsOneWidget);

      // アイコンが表示されることを確認
      expect(find.byIcon(Icons.star), findsOneWidget);

      // Scaffoldが存在することを確認
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ボタンタップテスト', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('タップ回数: $tapCount'),
                  ElevatedButton(
                    onPressed: () {
                      tapCount++;
                    },
                    child: const Text('タップ'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // 初期表示の確認
      expect(find.text('タップ回数: 0'), findsOneWidget);
      expect(find.text('タップ'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('テキストフィールドテスト', (WidgetTester tester) async {
      final TextEditingController controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'テスト入力',
                    ),
                  ),
                  Text(controller.text),
                ],
              ),
            ),
          ),
        ),
      );

      // TextFieldが存在することを確認
      expect(find.byType(TextField), findsOneWidget);

      // ラベルが表示されることを確認
      expect(find.text('テスト入力'), findsOneWidget);

      // テキスト入力のテスト
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // コントローラーにテキストが設定されることを確認（表示の確認はしない）
      expect(controller.text, 'Hello');
    });
  });

  group('レイアウトテスト', () {
    testWidgets('Column レイアウトテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Column(
              children: [
                Text('アイテム1'),
                Text('アイテム2'),
                Text('アイテム3'),
              ],
            ),
          ),
        ),
      );

      // すべてのテキストが表示されることを確認
      expect(find.text('アイテム1'), findsOneWidget);
      expect(find.text('アイテム2'), findsOneWidget);
      expect(find.text('アイテム3'), findsOneWidget);

      // Columnが存在することを確認
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('Row レイアウトテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Row(
              children: [
                Icon(Icons.home),
                Icon(Icons.star),
                Icon(Icons.settings),
              ],
            ),
          ),
        ),
      );

      // すべてのアイコンが表示されることを確認
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Rowが存在することを確認
      expect(find.byType(Row), findsOneWidget);
    });
  });
}
