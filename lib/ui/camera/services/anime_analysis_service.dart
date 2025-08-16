import 'dart:convert';
import 'package:http/http.dart' as http;

/// アニメリストから傾向分析コメントを生成するサービス
class AnimeAnalysisService {
  // FunctionsのエンドポイントURL（環境に合わせて修正してください）
  static const String functionsUrl =
      'https://us-central1-animeishi-73560.cloudfunctions.net/default';

  /// アニメリストから傾向分析コメントを生成（Firebase Functions経由）

  Future<String> analyzeAnimeTrends(List<Map<String, dynamic>> animeList,
      {String? username}) async {
    if (animeList.isEmpty) {
      return 'アニメの視聴履歴がありません。';
    }

    try {
      final response = await http.post(
        Uri.parse(functionsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'animeList': animeList,
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['comment'] ?? '傾向分析コメントを生成できませんでした。';
      } else {
        return 'AI分析に失敗しました: ${response.body}';
      }
    } catch (e) {
      return 'AI分析に失敗しました。しばらく時間をおいて再度お試しください。';
    }
  }
}
