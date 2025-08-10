#!/bin/bash

# Flutter CI スクリプト
# 使用方法: ./scripts/ci.sh

set -e  # エラーが発生したら即座に終了

echo "🚀 Flutter CI スクリプトを開始します..."

# 1. 依存関係の取得
echo "📦 依存関係を取得中..."
flutter pub get

# 2. コードフォーマットのチェック
echo "🎨 コードフォーマットをチェック中..."
if ! dart format --set-exit-if-changed .; then
    echo "❌ コードフォーマットに問題があります!"
    echo "修正するには: dart format ."
    exit 1
else
    echo "✅ コードフォーマット OK"
fi

# 3. 静的解析
echo "🔍 静的解析を実行中..."
flutter analyze --fatal-infos

# 4. テスト実行
echo "🧪 テストを実行中..."
flutter test

# 5. ビルドテスト（オプション）
if [ "$1" = "--build" ]; then
    echo "🏗️ ビルドテストを実行中..."
    flutter build apk --debug
fi

echo "✅ すべてのチェックが完了しました!"