import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('シンプルナビゲーションテスト', () {
    testWidgets('BottomNavigationBar基本構造テスト', (WidgetTester tester) async {
      // シンプルなテスト用ウィジェットを作成
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView(
              children: [
                Container(child: Text('ホーム')),
                Container(child: Text('アニメ')),
                Container(child: Text('スキャン')),
                Container(child: Text('フレンド')),
                Container(child: Text('プロフィール')),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.movie),
                  label: 'アニメ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.qr_code_scanner),
                  label: 'スキャン',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'フレンド',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'プロフィール',
                ),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarが存在することを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // BottomNavigationBarItemを直接検索できないため、アイコンで確認
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.movie), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      
      // 各タブのラベルを確認（複数の要素で同じテキストが使われる可能性があるため、最低限の確認）
      expect(find.text('ホーム'), findsAtLeastNWidgets(1));
      expect(find.text('アニメ'), findsAtLeastNWidgets(1));
      expect(find.text('スキャン'), findsAtLeastNWidgets(1));
      expect(find.text('フレンド'), findsAtLeastNWidgets(1));
      expect(find.text('プロフィール'), findsAtLeastNWidgets(1));

      // 基本的なアイコンの存在確認（BottomNavigationBarの内部構造は変わることがあるため）
      final bottomNavBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNavBar.items.length, 5);
    });

    testWidgets('PageView基本構造テスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView(
              children: [
                Container(child: Text('Page 1')),
                Container(child: Text('Page 2')),
                Container(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      // PageViewが存在することを確認
      expect(find.byType(PageView), findsOneWidget);
      
      // 初期ページの内容を確認
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('Material Design コンポーネントテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text('アニ名刺'),
            ),
            body: Center(
              child: Text('コンテンツ'),
            ),
          ),
        ),
      );

      // AppBarが存在することを確認
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('アニ名刺'), findsOneWidget);
      
      // Scaffoldが存在することを確認
      expect(find.byType(Scaffold), findsOneWidget);
      
      // コンテンツが表示されることを確認
      expect(find.text('コンテンツ'), findsOneWidget);
    });

    testWidgets('タッチターゲットサイズテスト', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '検索',
                ),
              ],
            ),
          ),
        ),
      );

      // BottomNavigationBarのサイズチェック
      final bottomNavBar = tester.getSize(find.byType(BottomNavigationBar));
      expect(bottomNavBar.height, greaterThanOrEqualTo(56.0)); // Material Design minimum
    });

    testWidgets('レスポンシブテスト - 小画面', (WidgetTester tester) async {
      // 小さい画面サイズを設定
      await tester.binding.setSurfaceSize(Size(320, 568));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: Text('小画面テスト')),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '検索',
                ),
              ],
            ),
          ),
        ),
      );

      // コンポーネントが正常に表示されることを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('小画面テスト'), findsOneWidget);
      
      // 画面サイズをリセット
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('レスポンシブテスト - 大画面', (WidgetTester tester) async {
      // 大きい画面サイズを設定
      await tester.binding.setSurfaceSize(Size(1024, 768));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: Text('大画面テスト')),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'ホーム',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: '検索',
                ),
              ],
            ),
          ),
        ),
      );

      // コンポーネントが正常に表示されることを確認
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('大画面テスト'), findsOneWidget);
      
      // 画面サイズをリセット
      await tester.binding.setSurfaceSize(null);
    });
  });
}