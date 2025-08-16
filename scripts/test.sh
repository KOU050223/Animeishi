#!/bin/bash

# Flutter テストスクリプト
# 使用方法: ./scripts/test.sh [options]

echo "🧪 テストを実行中..."

# 依存関係の確認
flutter pub get

# テストの実行（オプションがある場合はそれも渡す）
if [ $# -eq 0 ]; then
    # オプションがない場合は通常のテスト実行
    flutter test
else
    # オプションがある場合はそれを渡す（例: --coverage）
    flutter test "$@"
fi

echo "✅ テスト完了!"

# カバレッジレポートが生成された場合の表示
if [ -f "coverage/lcov.info" ]; then
    echo "📊 カバレッジレポートが生成されました: coverage/lcov.info"
fi