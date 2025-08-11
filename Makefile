# Flutter開発用 Makefile

# デフォルトターゲット
.DEFAULT_GOAL := help

# ヘルプ
.PHONY: help
help: ## このヘルプを表示
	@echo "利用可能なコマンド:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 依存関係の取得
.PHONY: deps
deps: ## 依存関係を取得
	flutter pub get

# コードフォーマット
.PHONY: format
format: ## コードをフォーマット
	dart format .

# フォーマットチェック
.PHONY: format-check
format-check: ## フォーマットをチェック（CI用）
	dart format --set-exit-if-changed .

# 静的解析
.PHONY: lint
lint: deps ## 静的解析を実行
	flutter analyze

# 厳密な静的解析
.PHONY: lint-strict
lint-strict: deps ## 厳密な静的解析を実行（CI用）
	flutter analyze

# テスト実行
.PHONY: test
test: deps ## テストを実行
	flutter test

# カバレッジ付きテスト
.PHONY: test-coverage
test-coverage: deps ## カバレッジ付きでテストを実行
	flutter test --coverage

# CI用の全チェック
.PHONY: ci
ci: deps format-check test ## CI用のすべてのチェックを実行
	@echo "✅ すべてのチェックが完了しました!"

# 開発環境の品質チェック（warningは許可）
.PHONY: check
check: deps format lint test ## 開発用の品質チェック
	@echo "✅ 開発環境チェック完了!"

# クリーンアップ
.PHONY: clean
clean: ## ビルドキャッシュをクリア
	flutter clean
	flutter pub get

# ビルド（デバッグ）
.PHONY: build-debug
build-debug: deps ## デバッグ用APKをビルド
	flutter build apk --debug

# ビルド（リリース）
.PHONY: build-release
build-release: ci ## リリース用APKをビルド
	flutter build apk --release

# 全フォーマット（修正も実行）
.PHONY: fix
fix: deps ## コードの自動修正を実行
	dart format .
	flutter analyze --fix