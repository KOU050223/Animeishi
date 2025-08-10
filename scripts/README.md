# 開発スクリプト

このディレクトリには、開発を効率化するためのスクリプトが含まれています。

## 利用可能なコマンド

### 1. Makefileを使用する方法（推奨）

```bash
# ヘルプを表示
make help

# CI用の全チェック（format-check + lint + test）
make ci

# 開発用チェック（warningは許可）
make check

# コードフォーマット
make format

# 静的解析
make lint

# テスト実行
make test

# カバレッジ付きテスト
make test-coverage

# 自動修正
make fix

# クリーンアップ
make clean
```

### 2. シェルスクリプトを使用する方法

```bash
# CI用の全チェック
./scripts/ci.sh

# ビルドテスト付きの場合
./scripts/ci.sh --build

# フォーマット
./scripts/format.sh

# 静的解析
./scripts/lint.sh

# テスト
./scripts/test.sh

# カバレッジ付きテスト
./scripts/test.sh --coverage
```

### 3. Dartスクリプトを使用する方法

```bash
# ヘルプを表示
dart run scripts/run.dart

# CI用の全チェック
dart run scripts/run.dart ci

# フォーマット
dart run scripts/run.dart format

# 静的解析
dart run scripts/run.dart lint

# テスト実行
dart run scripts/run.dart test

# カバレッジ付きテスト
dart run scripts/run.dart test --coverage

# 自動修正
dart run scripts/run.dart fix

# クリーンアップ
dart run scripts/run.dart clean
```

## 推奨される開発ワークフロー

### コード変更前
```bash
make check  # 現在のコード状態を確認
```

### コード変更後
```bash
make fix    # 自動修正を適用
make check  # 変更後の確認
```

### プルリクエスト前
```bash
make ci     # CI環境と同じチェックを実行
```

## CLAUDE.mdへの追加

これらのコマンドは既にCLAUDE.mdに記載されています：

```bash
# 基本コマンド
flutter analyze  # 静的解析
dart format .    # フォーマット
flutter test     # テスト

# 新しい統合コマンド
make ci         # 全チェック（推奨）
make check      # 開発用チェック
make fix        # 自動修正
```