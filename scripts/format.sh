#!/bin/bash

# Flutter フォーマットスクリプト
# 使用方法: ./scripts/format.sh

echo "🎨 コードをフォーマット中..."

# Dartコードをフォーマット
dart format .

echo "✅ フォーマット完了!"

# フォーマット結果を確認
echo "📋 フォーマット結果を確認中..."
if dart format --set-exit-if-changed . > /dev/null 2>&1; then
    echo "✅ コードフォーマットは正しく適用されています"
else
    echo "⚠️  一部のファイルでフォーマットが適用されていません"
fi