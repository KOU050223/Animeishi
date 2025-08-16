# アニ名刺 ビューアー

アニメ視聴履歴を共有するためのWebサイトです。

## 機能

- QRコードでユーザーIDを読み取り、視聴履歴を表示
- ユーザープロフィール表示
- 視聴済みアニメ一覧表示
- レスポンシブデザイン対応

## デプロイ手順

### 1. Firebase CLIのインストール

```bash
npm install -g firebase-tools
```

### 2. Firebaseにログイン

```bash
firebase login
```

### 3. プロジェクトの初期化

```bash
cd viewer
firebase init hosting
```

### 4. デプロイ

```bash
firebase deploy
```

## ファイル構成

```
viewer/
├── public/
│   ├── index.html          # メインページ
│   ├── user.html           # ユーザー詳細ページ
│   └── assets/
│       ├── css/
│       │   └── style.css   # スタイルシート
│       └── js/
│           ├── app.js      # メインアプリケーション
│           └── firebase-config.js  # Firebase設定
├── firebase.json           # Firebase設定
└── .firebaserc            # プロジェクト設定
```

## URL構成

- `/` - ランディングページ
- `/user/{userId}` - ユーザー詳細ページ

## 技術スタック

- HTML5
- CSS3
- JavaScript (ES6+)
- Firebase Hosting
- Firebase Firestore
