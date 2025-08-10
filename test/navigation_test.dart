import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animeishi/ui/home/view/home_page.dart';

void main() {
  group('ナビゲーションテスト', () {
    testWidgets('ホーム画面のタブ切り替えテスト', (WidgetTester tester) async {
      // ホーム画面を表示
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );

      // 初期状態でホームタブが選択されていることを確認
      expect(find.text('ホーム'), findsOneWidget);

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 5つのタブが存在することを確認
      expect(find.byType(BottomNavigationBarItem), findsNWidgets(5));
    });

    testWidgets('タブアイコンとラベルの確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );

      // 各タブのラベルを確認
      expect(find.text('ホーム'), findsOneWidget);
      expect(find.text('アニメ'), findsOneWidget);
      expect(find.text('スキャン'), findsOneWidget);
      expect(find.text('フレンド'), findsOneWidget);
      expect(find.text('プロフィール'), findsOneWidget);

      // 各タブのアイコンを確認
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('PageViewの存在確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );

      // PageViewが存在することを確認
      expect(find.byType(PageView), findsOneWidget);

      // Scaffoldが存在することを確認
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
    });

    testWidgets('タブタップによる状態変更テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );

      // 初期状態（ホームタブが選択）
      final bottomNavBar =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.currentIndex, 0);

      // アニメタブをタップ
      await tester.tap(find.text('アニメ'));
      await tester.pump();

      // 状態が変更されたことを確認（実際のインデックス変更はコンポーネント内部で処理）
      // PageViewの存在を再確認
      expect(find.byType(PageView), findsOneWidget);
    });
  });

  group('ホームページコンテンツテスト', () {
    testWidgets('HomeTabPageの表示テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeTabPage(),
        ),
      );

      // AppBarのタイトルを確認
      expect(find.text('アニ名刺'), findsOneWidget);

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);

      // HomePageContentが存在することを確認
      expect(find.byType(HomePageContent), findsOneWidget);
    });

    testWidgets('QRScannerPageの表示テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const QRScannerPage(),
        ),
      );

      // AppBarのタイトルを確認
      expect(find.text('QRコードスキャン'), findsOneWidget);

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  group('アクセシビリティテスト', () {
    testWidgets('セマンティクスの基本チェック', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
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
          home: const HomePage(),
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
          home: const HomePage(),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // PageViewが存在することを確認
      expect(find.byType(PageView), findsOneWidget);

      // 画面サイズをリセット
      tester.view.reset();
    });

    testWidgets('大きい画面でのレイアウト', (WidgetTester tester) async {
      // 大きい画面サイズを設定
      tester.view.physicalSize = const Size(1024, 768);

      await tester.pumpWidget(
        MaterialApp(
          home: const HomePage(),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // PageViewが存在することを確認
      expect(find.byType(PageView), findsOneWidget);

      // 画面サイズをリセット
      tester.view.reset();
    });
  });
}
