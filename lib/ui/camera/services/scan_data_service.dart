import 'package:cloud_firestore/cloud_firestore.dart';

/// QRスキャンデータ処理サービス
class ScanDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ユーザーデータを取得する
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      print('ユーザーデータ取得: $userId');
      print(doc);

      if (doc.exists) {
        return doc.data();
      } else {
        print('ユーザーが存在しません: $userId');
      }
    } catch (e) {
      print('ユーザーデータ取得エラー: $e');
    }
    return null;
  }

  /// ユーザーが選択したアニメのTIDを取得する
  static Future<Set<String>> getSelectedAnimeTIDs(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .get();

      // 各ドキュメントのIDがTIDとして登録されていると仮定
      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      print('selectedAnime 取得エラー: $e');
      return {};
    }
  }

  /// 取得したTIDに基づいて、アニメ詳細情報を取得する
  static Future<List<Map<String, dynamic>>> getAnimeDetails(
    Set<String> tids,
  ) async {
    List<Map<String, dynamic>> animeList = [];
    try {
      // "titles" コレクションから全件取得（件数が多い場合は where クエリなどで絞ることを検討）
      final snapshot = await _firestore.collection('titles').get();

      for (var doc in snapshot.docs) {
        if (tids.contains(doc.id)) {
          // 'Title' フィールドにアニメの名前が入っていると仮定
          animeList.add({
            'tid': doc.id,
            'title': doc.data()['Title'] ?? 'タイトル未設定',
          });
        }
      }
    } catch (e) {
      print('アニメ詳細取得エラー: $e');
    }
    return animeList;
  }

  /// ユーザーデータとアニメ詳細情報の両方を取得する
  static Future<ScanDataResult> fetchUserData(String userId) async {
    try {
      final userData = await getUserData(userId);

      if (userData == null) {
        return ScanDataResult(
          success: false,
          errorType: ScanDataErrorType.userNotFound,
        );
      }

      final tids = await getSelectedAnimeTIDs(userId);
      final animeDetails = await getAnimeDetails(tids);

      return ScanDataResult(
        success: true,
        userData: userData,
        animeList: animeDetails,
      );
    } catch (e) {
      print('データ取得エラー: $e');
      return ScanDataResult(
        success: false,
        errorType: ScanDataErrorType.networkError,
        errorMessage: e.toString(),
      );
    }
  }

  /// QRコードの値からユーザーIDを抽出する
  static String? extractUserIdFromQR(String? qrValue) {
    if (qrValue == null || qrValue.trim().isEmpty) {
      return null;
    }

    final trimmedValue = qrValue.trim();

    // URLフォーマットの場合: https://animeishi-viewer.web.app/user/USER_ID
    if (trimmedValue.startsWith('https://animeishi-viewer.web.app/user/')) {
      final userId = trimmedValue.substring(
        'https://animeishi-viewer.web.app/user/'.length,
      );
      return userId.isNotEmpty ? userId : null;
    }

    // 直接ユーザーIDが渡された場合（従来の動作を維持）
    if (trimmedValue.length >= 3) {
      return trimmedValue;
    }

    return null;
  }

  /// ユーザーデータの基本情報を整形する
  static UserProfile parseUserProfile(Map<String, dynamic> userData) {
    return UserProfile(
      username: userData['username'] ?? '名前未設定',
      email: userData['email'] ?? '',
      selectedGenres: List<String>.from(userData['selectedGenres'] ?? []),
      profileImageUrl: userData['profileImageUrl'] ?? '',
      bio: userData['bio'] ?? '',
      favoriteQuote: userData['favoriteQuote'] ?? '',
    );
  }

  /// analysisCommentを取得
  static Future<String?> getAnalysisComment(
    String currentUserId,
    String friendUserId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('meishies')
          .doc(friendUserId)
          .get();
      if (doc.exists) {
        return doc.data()?['analysisComment'] as String?;
      }
    } catch (e) {
      print('analysisComment取得エラー: $e');
    }
    return null;
  }

  /// analysisCommentを保存
  static Future<void> saveAnalysisComment(
    String currentUserId,
    String friendUserId,
    String comment,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('meishies')
          .doc(friendUserId)
          .set({
        'analysisComment': comment,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('analysisComment保存成功: $currentUserId -> $friendUserId');
    } catch (e) {
      print('analysisComment保存エラー: $e');
      rethrow;
    }
  }
}

/// スキャンデータ取得結果を格納するクラス
class ScanDataResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final List<Map<String, dynamic>>? animeList;
  final ScanDataErrorType? errorType;
  final String? errorMessage;

  ScanDataResult({
    required this.success,
    this.userData,
    this.animeList,
    this.errorType,
    this.errorMessage,
  });
}

/// スキャンデータエラーの種類
enum ScanDataErrorType {
  userNotFound,
  networkError,
  invalidQR,
  permissionDenied,
}

/// ユーザープロフィール情報
class UserProfile {
  final String username;
  final String email;
  final List<String> selectedGenres;
  final String profileImageUrl;
  final String bio;
  final String favoriteQuote;

  UserProfile({
    required this.username,
    required this.email,
    required this.selectedGenres,
    required this.profileImageUrl,
    required this.bio,
    required this.favoriteQuote,
  });
}
