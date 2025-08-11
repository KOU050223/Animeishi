#!/bin/bash

# Flutter Lintスクリプト
# 使用方法: ./scripts/lint.sh

echo "🔍 静的解析を実行中..."

# 依存関係の確認
flutter pub get

# 静的解析の実行
flutter analyze

echo "✅ 静的解析完了!"

# 結果のサマリーを表示
echo ""
echo "📊 解析結果のサマリー:"
flutter analyze 2>&1 | grep -E "(error|warning|info)" | sort | uniq -c | sort -nr || echo "問題は見つかりませんでした"