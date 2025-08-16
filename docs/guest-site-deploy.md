# ゲストサイト（viewer）デプロイ方法

## 概要

このドキュメントでは、Firebase Hostingのマルチサイト機能を使用して、viewerアプリを別のサイトとしてデプロイする方法を説明します。

## 前提条件

- Firebase CLIがインストールされている
- Firebaseプロジェクト（animeishi-73560）にアクセス権限がある
- Flutterアプリが既にメインサイトにデプロイされている

## デプロイ手順

### 1. Firebase側の設定

#### 1.1 新しいサイトの作成

1. **Firebase Console**にアクセス
2. **Hosting**ページに移動
3. **「別のサイトを追加」**ボタンをクリック
4. サイトIDを入力：`animeishi-viewer`
5. **「サイトを追加」**をクリック

#### 1.2 認証済みドメインの追加（必要に応じて）

1. **Authentication** → **Settings** → **Authorized domains**
2. **「ドメインを追加」**をクリック
3. `animeishi-viewer.web.app`を追加

### 2. ローカル環境での設定

#### 2.1 viewerディレクトリに移動

```bash
cd viewer
```

#### 2.2 Firebase初期化

```bash
firebase init hosting
```

設定内容：
- **Public directory**: `public`
- **Single-page app**: `No`
- **GitHub自動デプロイ**: `No`
- **既存ファイルの上書き**: `N`（既存のindex.htmlを保持）

#### 2.3 ターゲット設定

```bash
firebase target:apply hosting viewer-site animeishi-viewer
```

#### 2.4 firebase.jsonの設定

```json
{
  "hosting": {
    "target": "viewer-site",
    "public": "public",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "/user/**",
        "destination": "/user.html"
      }
    ]
  }
}
```

#### 2.5 .firebasercの確認

```json
{
  "projects": {
    "default": "animeishi-73560"
  },
  "targets": {
    "animeishi-73560": {
      "hosting": {
        "viewer-site": [
          "animeishi-viewer"
        ]
      }
    }
  }
}
```

### 3. デプロイ

#### 3.1 viewerサイトのデプロイ

```bash
firebase deploy --only hosting:viewer-site
```

#### 3.2 デプロイ確認

- **URL**: `https://animeishi-viewer.web.app`
- Firebase Consoleでデプロイ履歴を確認

### 4. Flutterアプリの設定更新

#### 4.1 QRコードURLの更新

`lib/ui/home/view/home_page.dart`を編集：

```dart
final String qrData = user?.uid != null 
    ? "https://animeishi-viewer.web.app/user/${user!.uid}"
    : "No UID";
```

#### 4.2 Flutterアプリの再デプロイ

```bash
flutter build web
firebase deploy --only hosting
```

## サイト構成

### メインサイト（Flutterアプリ）
- **URL**: `https://animeishi-73560.web.app`
- **用途**: アプリのメイン機能
- **デプロイ先**: プロジェクトのルート

### ゲストサイト（viewerアプリ）
- **URL**: `https://animeishi-viewer.web.app`
- **用途**: ユーザーの視聴履歴表示
- **デプロイ先**: `viewer`ディレクトリ

## トラブルシューティング

### よくある問題

#### 1. デプロイエラー

```bash
# ログイン確認
firebase login

# プロジェクト確認
firebase projects:list

# ターゲット確認
firebase target
```

#### 2. ファイルが見つからない

```bash
# ファイル構造確認
ls -la public/

# 必要なファイルの存在確認
ls -la public/index.html
ls -la public/assets/js/
```

#### 3. Firebase初期化エラー

```bash
# 設定ファイルの確認
cat firebase.json
cat .firebaserc

# 必要に応じて再初期化
firebase init hosting
```

### デバッグ方法

#### 1. ローカルテスト

```bash
# ローカルサーバー起動
firebase serve --only hosting:viewer-site

# ブラウザで確認
# http://localhost:5000
```

#### 2. ログ確認

```bash
# デプロイログの詳細表示
firebase deploy --only hosting:viewer-site --debug
```

## メンテナンス

### 定期的な作業

1. **セキュリティ更新**: Firebase SDKの更新
2. **パフォーマンス監視**: ページ読み込み速度の確認
3. **エラー監視**: ブラウザコンソールでのエラー確認

### 更新手順

1. **コード変更**
2. **ローカルテスト**
3. **デプロイ**
4. **動作確認**

## 参考リンク

- [Firebase Hosting マルチサイト](https://firebase.google.com/docs/hosting/multisites?hl=ja)
- [Firebase CLI リファレンス](https://firebase.google.com/docs/cli?hl=ja)
- [Firebase Hosting クイックスタート](https://firebase.google.com/docs/hosting/quickstart?hl=ja)

## 更新履歴

- 2025/08/16: 初版作成
- マルチサイト機能を使用したviewerアプリのデプロイ方法を追加
