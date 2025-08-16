fierbase_storageのweb実装に伴いCORS設定を行っています

以下のコマンドをプロジェクトルートで実行します

```bash
# GoogleCloudにログイン
gcloud auth login

# CORS.jsonを参照してCORS設定をする
gsutil cors set cors.json gs://animeishi-73560.firebasestorage.app

# > Setting CORS on gs://animeishi-73560.firebasestorage.app/...
```