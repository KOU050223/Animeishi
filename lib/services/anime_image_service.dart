import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AnimeImageService {
  static const String baseUrl = 'https://api.anime-sommelier.com/v1/tid';

  // キャッシュ管理
  static final Map<String, String?> _imageCache = {};
  static final Map<String, Future<String?>> _pendingRequests = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration cacheExpiration = Duration(hours: 24); // 24時間キャッシュ
  static const int maxConcurrentRequests = 3; // 同時リクエスト数制限
  static int _activeRequestCount = 0;

  // Web版でCORS問題を回避するためのプロキシURL（フォールバック付き）
  static const List<String> corsProxyUrls = [
    'https://api.allorigins.win/get?url=',
    'https://corsproxy.io/?',
    'https://cors-anywhere.herokuapp.com/',
  ];

  // Web版でCORS問題がある場合のフォールバック画像（より美しく）
  static const Map<String, String> fallbackImages = {
    '1':
        'https://via.placeholder.com/150x200/6366f1/ffffff?text=%E9%AD%94%E6%B3%95%E9%81%A3%E3%81%84',
    '2':
        'https://via.placeholder.com/150x200/06b6d4/ffffff?text=%E3%82%BD%E3%83%8B%E3%83%83%E3%82%AFX',
    '3':
        'https://via.placeholder.com/150x200/f59e0b/ffffff?text=%E9%80%B2%E6%92%83%E3%81%AE%E5%B7%A8%E4%BA%BA',
    '4':
        'https://via.placeholder.com/150x200/10b981/ffffff?text=%E3%83%92%E3%83%BC%E3%83%AD%E3%83%BC',
    '5':
        'https://via.placeholder.com/150x200/f43f5e/ffffff?text=%E9%AC%BC%E6%BB%85%E3%81%AE%E5%88%83',
    '100':
        'https://via.placeholder.com/150x200/8b5cf6/ffffff?text=%E3%82%B3%E3%82%B9%E3%83%A2%E3%82%B9%E8%8D%98',
  };

  /// TIDを指定してアニメの画像URLを取得（キャッシュ付き）
  static Future<String?> getImageUrl(String tid) async {
    // キャッシュから確認
    if (_imageCache.containsKey(tid)) {
      final cachedTimestamp = _cacheTimestamps[tid];
      if (cachedTimestamp != null &&
          DateTime.now().difference(cachedTimestamp) < cacheExpiration) {
        return _imageCache[tid];
      } else {
        // 期限切れキャッシュを削除
        _imageCache.remove(tid);
        _cacheTimestamps.remove(tid);
      }
    }

    // 既に進行中のリクエストがある場合はそれを返す
    if (_pendingRequests.containsKey(tid)) {
      return await _pendingRequests[tid]!;
    }

    // 同時リクエスト数制限チェック
    if (_activeRequestCount >= maxConcurrentRequests) {
      return fallbackImages[tid];
    }

    // 新しいリクエストを開始
    _activeRequestCount++;
    final future = kIsWeb ? _getImageUrlWeb(tid) : _getImageUrlNative(tid);
    _pendingRequests[tid] = future;

    try {
      final result = await future;

      // キャッシュに保存
      _imageCache[tid] = result;
      _cacheTimestamps[tid] = DateTime.now();

      return result;
    } finally {
      // クリーンアップ
      _activeRequestCount--;
      _pendingRequests.remove(tid);
    }
  }

  /// ネイティブ版での画像URL取得
  static Future<String?> _getImageUrlNative(String tid) async {
    try {
      final uri = Uri.parse('$baseUrl/$tid/');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'AnimeishiApp/1.0',
        },
      ).timeout(Duration(seconds: 8));

      return _parseResponse(response, tid);
    } catch (e) {
      return fallbackImages[tid];
    }
  }

  /// Web版での画像URL取得（複数プロキシ試行）
  static Future<String?> _getImageUrlWeb(String tid) async {
    final originalUrl = Uri.encodeComponent('$baseUrl/$tid/');

    // 各プロキシを短いタイムアウトで試行
    for (int i = 0; i < corsProxyUrls.length; i++) {
      try {
        final proxyUrl = corsProxyUrls[i];
        final uri = Uri.parse('$proxyUrl$originalUrl');

        final response = await http.get(
          uri,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'AnimeishiApp/1.0',
          },
        ).timeout(Duration(seconds: 5)); // より短いタイムアウト

        final result = _parseResponse(response, tid, isWeb: true);
        if (result != null) {
          return result;
        }
      } catch (e) {
        // 次のプロキシを試行
        continue;
      }
    }

    // すべてのプロキシが失敗した場合
    final fallbackUrl = fallbackImages[tid];
    return fallbackUrl;
  }

  /// レスポンスを解析して画像URLを取得
  static String? _parseResponse(http.Response response, String tid,
      {bool isWeb = false}) {
    try {
      if (response.statusCode == 200) {
        dynamic data;

        // Web版でプロキシを使用した場合のレスポンス処理
        if (isWeb && response.body.contains('contents')) {
          final proxyResponse = json.decode(response.body);
          if (proxyResponse['contents'] != null) {
            data = json.decode(proxyResponse['contents']);
          }
        } else {
          data = json.decode(response.body);
        }

        // レスポンスが配列の場合（APIは配列で返す）
        if (data is List && data.isNotEmpty) {
          final firstItem = data[0];
          if (firstItem['image'] != null) {
            final imageUrl = firstItem['image'] as String;
            return imageUrl;
          }
        }

        // レスポンスがオブジェクトの場合
        if (data is Map && data['image'] != null) {
          final imageUrl = data['image'] as String;
          return imageUrl;
        }
      } else {
        print(
            'HTTP error for TID $tid: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error parsing response for TID $tid: $e');
    }

    return null;
  }

  /// 複数のTIDに対して画像URLを一括取得（効率化版）
  static Future<Map<String, String?>> getImageUrls(List<String> tids) async {
    final Map<String, String?> imageUrls = {};
    final List<String> uncachedTids = [];

    // まずキャッシュから取得可能なものを処理
    for (final tid in tids) {
      if (_imageCache.containsKey(tid)) {
        final cachedTimestamp = _cacheTimestamps[tid];
        if (cachedTimestamp != null &&
            DateTime.now().difference(cachedTimestamp) < cacheExpiration) {
          imageUrls[tid] = _imageCache[tid];
          continue;
        }
      }
      uncachedTids.add(tid);
    }

    // 未キャッシュのTIDを小分けして処理（負荷軽減）
    const batchSize = 3;
    for (int i = 0; i < uncachedTids.length; i += batchSize) {
      final batchEnd = (i + batchSize < uncachedTids.length)
          ? i + batchSize
          : uncachedTids.length;
      final batch = uncachedTids.sublist(i, batchEnd);

      // バッチ内で並行処理
      final futures = batch.map((tid) => getImageUrl(tid));
      final results = await Future.wait(futures);

      for (int j = 0; j < batch.length; j++) {
        imageUrls[batch[j]] = results[j];
      }

      // バッチ間で少し待機（API負荷軽減）
      if (i + batchSize < uncachedTids.length) {
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    return imageUrls;
  }

  /// キャッシュを考慮した画像URL取得（Firestoreキャッシュと組み合わせて使用）
  static Future<String?> getCachedImageUrl(String tid) async {
    // 将来的にFirestoreでキャッシュする場合のメソッド
    // 現在は直接APIから取得
    return await getImageUrl(tid);
  }

  /// キャッシュクリア機能
  static void clearCache() {
    _imageCache.clear();
    _cacheTimestamps.clear();
  }

  /// キャッシュ統計を取得
  static Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int validCache = 0;
    int expiredCache = 0;

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) < cacheExpiration) {
        validCache++;
      } else {
        expiredCache++;
      }
    }

    return {
      'totalCached': _imageCache.length,
      'validCache': validCache,
      'expiredCache': expiredCache,
      'activeRequests': _activeRequestCount,
      'pendingRequests': _pendingRequests.length,
    };
  }
}
