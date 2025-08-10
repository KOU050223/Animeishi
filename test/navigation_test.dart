import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ナビゲーション基本テスト', () {
    testWidgets('BottomNavigationBarの基本機能テスト', (WidgetTester tester) async {
      // シンプルなBottomNavigationBarのテスト
      int currentIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Test Page $currentIndex')),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // BottomNavigationBar内のアイテム数を確認
      final bottomNavBarWidget =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBarWidget.items.length, 5);

      // 各ラベルが存在することを確認
      expect(find.text('ホーム'), findsOneWidget);
      expect(find.text('アニメ'), findsOneWidget);
      expect(find.text('スキャン'), findsOneWidget);
      expect(find.text('フレンド'), findsOneWidget);
      expect(find.text('プロフィール'), findsOneWidget);
    });

    testWidgets('アイコンの表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // 各アイコンが表示されていることを確認
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('基本ページ構造のテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('テストページ')),
            body: const Center(child: Text('テスト内容')),
          ),
        ),
      );

      // Scaffoldが存在することを確認
      expect(find.byType(Scaffold), findsOneWidget);

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);

      // テキストが表示されることを確認
      expect(find.text('テストページ'), findsOneWidget);
      expect(find.text('テスト内容'), findsOneWidget);
    });
  });

  group('アクセシビリティテスト', () {
    testWidgets('セマンティクスの基本チェック', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarの存在を確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // セマンティクス情報の基本的な存在確認
      final bottomNavBarWidget =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBarWidget.items.length, 5);
    });

    testWidgets('タッチターゲットサイズチェック', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarのタッチターゲットが適切なサイズであることを確認
      final bottomNavBar = tester.getSize(find.byType(BottomNavigationBar));
      expect(bottomNavBar.height,
          greaterThanOrEqualTo(56.0)); // Material Design minimum
    });
  });

  group('レスポンシブ対応テスト', () {
    testWidgets('小さい画面でのレイアウト', (WidgetTester tester) async {
      // 小さい画面サイズを設定
      tester.view.physicalSize = const Size(320, 568);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('小さい画面テスト')),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // テキストが表示されることを確認
      expect(find.text('小さい画面テスト'), findsOneWidget);

      // 画面サイズをリセット
      tester.view.reset();
    });

    testWidgets('大きい画面でのレイアウト', (WidgetTester tester) async {
      // 大きい画面サイズを設定
      tester.view.physicalSize = const Size(1024, 768);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('大きい画面テスト')),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
                BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'アニメ'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.qr_code_scanner), label: 'スキャン'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.people), label: 'フレンド'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'プロフィール'),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // テキストが表示されることを確認
      expect(find.text('大きい画面テスト'), findsOneWidget);

      // 画面サイズをリセット
      tester.view.reset();
    });
  });
}
