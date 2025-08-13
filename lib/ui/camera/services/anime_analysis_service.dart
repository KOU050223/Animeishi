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

  /// アニメリストから傾向分析コメントを生成
  Future<String> analyzeAnimeTrends(List<Map<String, dynamic>> animeList, {String? username}) async {
    if (animeList.isEmpty) {
      return 'アニメの視聴履歴がありません。';
    }

    final titles = animeList.map((a) => a['title'] ?? '').where((t) => t.isNotEmpty).toList();
    final prompt = '''
${username != null ? "$usernameさん" : "このユーザー"}のアニメ視聴傾向を分析してください。
以下は最近視聴・選択したアニメタイトル一覧です。
${titles.map((t) => "- $t").join('\n')}

傾向や好み、ジャンル、性格などを推測し、100文字程度でコメントしてください。
必ず日本語で回答してください。
''';

    try {
      final response = await _generativeModel.generateContent([
        Content.text(prompt),
      ]);
      return response.text ?? '傾向分析コメントを生成できませんでした。';
    } catch (e) {
      return 'AI分析に失敗しました。しばらく時間をおいて再度お試しください。';
    }
  }
}
