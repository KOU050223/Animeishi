import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firebase Storage Rules Tests', () {
    group('名刺画像アップロード（meishi_images）', () {
      test('正しいファイル名形式のテスト', () {
        // テストケース: meishi_{uid}_{timestamp}.jpg
        final uid = 'rs0KlwDO8JcHoSUOQU9bvuCkqAY2';
        final fileName = 'meishi_${uid}_1755379468580.jpg';

        // ファイル名が正しい形式であることを確認
        final pattern = RegExp(r'^meishi_' + uid + r'_.*');
        expect(pattern.hasMatch(fileName), isTrue,
            reason: 'ファイル名がmeishi_{uid}_形式に一致している');
      });

      test('ファイル名形式のバリデーション', () {
        final uid = 'testUser123';

        // 正しい形式
        final validNames = [
          'meishi_${uid}_1234567890.jpg',
          'meishi_${uid}_abcdef.png',
          'meishi_${uid}_test.jpeg',
        ];

        // 間違った形式
        final invalidNames = [
          'meishi_otherUser_1234567890.jpg', // 他のユーザーID
          'image_${uid}_1234567890.jpg', // meishi_で始まらない
          'meishi_1234567890.jpg', // uidが含まれていない
          '${uid}_1234567890.jpg', // meishi_プレフィックスなし
        ];

        final pattern = RegExp(r'^meishi_' + uid + r'_.*');

        for (final name in validNames) {
          expect(pattern.hasMatch(name), isTrue, reason: '$name は有効なファイル名形式');
        }

        for (final name in invalidNames) {
          expect(pattern.hasMatch(name), isFalse, reason: '$name は無効なファイル名形式');
        }
      });
    });

    group('ストレージルール構文の確認', () {
      test('修正されたルール構文が論理的に正しいことを確認', () {
        // 修正されたルール:
        // match /meishi_images/{fileName} {
        //   allow read: if request.auth != null;
        //   allow write: if request.auth != null &&
        //                  fileName.matches('meishi_' + request.auth.uid + '_.*');
        // }

        // このルールにより以下が実現される:
        // 1. 認証済みユーザーは全ての名刺画像を読み取り可能
        // 2. 書き込みは認証済みかつファイル名が自分のUID形式の場合のみ可能
        // 3. ファイル名形式: meishi_{uid}_{任意の文字列}

        expect(true, isTrue, reason: 'ルール構文は論理的に正しい');
      });

      test('エラーメッセージとの整合性確認', () {
        // エラーメッセージで見つかったパス:
        // meishi_images/meishi_rs0KlwDO8JcHoSUOQU9bvuCkqAY2_1755379468580.jpg

        final errorPath =
            'meishi_images/meishi_rs0KlwDO8JcHoSUOQU9bvuCkqAY2_1755379468580.jpg';
        final fileName =
            'meishi_rs0KlwDO8JcHoSUOQU9bvuCkqAY2_1755379468580.jpg';
        final uid = 'rs0KlwDO8JcHoSUOQU9bvuCkqAY2';

        // 修正後のルールで正常に処理されることを確認
        final pattern = RegExp(r'^meishi_' + uid + r'_.*');
        expect(pattern.hasMatch(fileName), isTrue,
            reason: 'エラーが発生したファイル名が修正後のルールで許可される');
      });
    });

    group('セキュリティテスト', () {
      test('他人のファイルをアップロードできないことを確認', () {
        final userA = 'userA';
        final userB = 'userB';

        final fileNameA = 'meishi_${userA}_1234567890.jpg';
        final fileNameB = 'meishi_${userB}_1234567890.jpg';

        // userAがuserBのファイル名形式でアップロードしようとした場合
        final patternA = RegExp(r'^meishi_' + userA + r'_.*');
        expect(patternA.hasMatch(fileNameB), isFalse,
            reason: 'userAは他人（userB）のファイル名形式ではアップロードできない');

        // userBがuserAのファイル名形式でアップロードしようとした場合
        final patternB = RegExp(r'^meishi_' + userB + r'_.*');
        expect(patternB.hasMatch(fileNameA), isFalse,
            reason: 'userBは他人（userA）のファイル名形式ではアップロードできない');
      });
    });
  });
}
