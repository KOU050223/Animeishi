# 【アニ名刺】

視聴したアニメのリストを相手と共有することを目的としたアプリ

## 作った背景

アニメ好きと会話をする時に、相手が見たことのあるアニメを探るパートが大変だと感じたため...
"アニメ好き"の範囲が広すぎるんじゃぁぁぁぁ

## ユーザーフロー

1. ログイン(FirebaseAuth)を行う
2. 視聴したアニメを登録する(ソート・検索可能)
3. QRを使ってフレンド登録をする
4. フレンドの情報見れてハッピー！

## 使用技術

- Flutter
  - qr_flutter
- Firebase
  - Auth
  - FireStore
  - Hosting
  - Functions

## データ取得

[しょぼいカレンダー](https://docs.cal.syoboi.jp/spec/db.php/)というサイトからアニメデータを取得しています
ありがとうございますm(_ _)m
Firebase FunctionsがPub/Subのスケジュールにて週１回FireStoreのデータを更新するようにしています

## フレンド交換

ユーザーIDを含むQRを相手の端末で読み込むことでフレンドになることができます
フレンドになったユーザーの視聴したアニメリストを見ることができます

### アーキテクチャ

![image](https://ptera-publish.topaz.dev/project/01K1B7K4YV9WBVHRF857B0N55P.png)

## 今後の展望

- リリース
- 名刺機能を強化
- UI/UXを強化
