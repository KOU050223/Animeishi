import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// アニメ視聴傾向分析サービス
class AnimeAnalysisService {
  late final GenerativeModel _generativeModel;

  AnimeAnalysisService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('Gemini APIキーが設定されていません');
    }
    _generativeModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
  }

  /// アニメリストから傾向分析コメントを生成し、Firestoreに保存
  Future<String> analyzeAndSaveAnimeTrends({
    required List<Map<String, dynamic>> animeList,
    required String friendUserId,
    String? username,
  }) async {
    if (animeList.isEmpty) {
      return 'アニメの視聴履歴がありません。';
    }

    final titles = animeList.map((a) => a['title'] ?? '').where((t) => t.isNotEmpty).toList();
    final prompt = '''
${username != null ? "$usernameさん" : "このユーザー"}のアニメ視聴傾向を分析してください。
以下は最近視聴・選択したアニメタイトル一覧です。
${titles.map((t) => "- $t").join('\n')}

傾向や好み、ジャンル、性格などを推測し、100文字程度でコメントしてください。
''';

    String comment;
    try {
      final response = await _generativeModel.generateContent([
        Content.text(prompt),
      ]);
      comment = response.text ?? '傾向分析コメントを生成できませんでした。';
    } catch (e) {
      comment = 'AI分析に失敗しました: $e';
    }

    // Firestoreに保存
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('未認証ユーザー');

      print('[AnimeAnalysisService] Firestore保存: /users/${currentUser.uid}/meishies/$friendUserId analysisComment');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('meishies')
          .doc(friendUserId)
          .update({'analysisComment': comment});
      print('[AnimeAnalysisService] 保存完了: $comment');
    } catch (e) {
      print('[AnimeAnalysisService] 分析コメント保存エラー: $e');
    }

    return comment;
  }
}
