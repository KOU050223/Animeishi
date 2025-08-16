# Firebase Storage CORS設定

Firebase StorageのWeb実装に伴いCORS設定を行っています。

## 許可するorigin

以下のドメインからのアクセスを許可します：

- `https://animeishi-73560*.web.app` (Firebase Hosting - ワイルドカード対応)
- `https://animeishi.uomi.site` (カスタムドメイン)  
- `https://animeishi-73560.firebaseapp.com` (Firebase App)

## CORS設定の適用手順

以下のコマンドをプロジェクトルートで実行します：

```bash
# Google Cloudにログイン
gcloud auth login

# cors.jsonを参照してCORS設定を適用
gsutil cors set cors.json gs://animeishi-73560.firebasestorage.app

# 設定確認
gsutil cors get gs://animeishi-73560.firebasestorage.app
```

## 設定ファイル

- `cors.json`: Google Cloud Storage用のCORS設定
- `firebase.json`: Firebase用のCORS設定（両方に設定）

## セキュリティ考慮

ワイルドカード（`*`）ではなく、特定のドメインのみを許可することでセキュリティを向上させています。