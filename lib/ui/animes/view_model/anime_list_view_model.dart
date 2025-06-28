import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';

enum SortOrder { tid, year, name }

class AnimeListViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _animeList = [];
  List<Map<String, dynamic>> _filteredAnimeList = [];
  bool _isLoading = false;
  Set<String> _selectedAnime = {}; // 一時的に選択されたアニメのTIDを保持するセット
  Set<String> _registeredAnime = {}; // 登録済みアニメのTIDを保持するセット
  SortOrder _sortOrder = SortOrder.tid; //デフォルトはtid順
  bool _isAscending = true; //デフォルトは昇順
  bool _disposed = false; // dispose状態を追跡
  String _searchQuery = ''; // 検索クエリ

  List<Map<String, dynamic>> get animeList => _filteredAnimeList.isNotEmpty || _searchQuery.isNotEmpty 
      ? _filteredAnimeList 
      : _animeList;
  bool get isLoading => _isLoading;
  Set<String> get selectedAnime => _selectedAnime; // 一時的に選択されたアニメのTIDを取得するゲッター
  Set<String> get registeredAnime => _registeredAnime; // 登録済みアニメのTIDを取得するゲッター
  SortOrder get sortOrder => _sortOrder; //ソート順を取得するゲッター
  bool get isAscending => _isAscending; //昇順 or 降順を取得
  String get searchQuery => _searchQuery; // 検索クエリを取得するゲッター

  //ソート順の変更
  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    sortAnimeList(); // ソートを適用
  }

  //昇順・降順を切り替える
  void toggleSortOrder() {
    _isAscending = !_isAscending;
    sortAnimeList();
  }

  // 検索機能
  void searchAnime(String query) {
    _searchQuery = query.toLowerCase();
    if (_searchQuery.isEmpty) {
      _filteredAnimeList = [];
    } else {
      _filteredAnimeList = _animeList.where((anime) {
        final title = anime['title'].toString().toLowerCase();
        final titleYomi = anime['titleyomi'].toString().toLowerCase();
        final tid = anime['tid'].toString();
        final year = anime['firstyear'].toString();
        
        return title.contains(_searchQuery) ||
               titleYomi.contains(_searchQuery) ||
               tid.contains(_searchQuery) ||
               year.contains(_searchQuery);
      }).toList();
      
      // 検索結果もソートする
      _sortFilteredList();
    }
    _safeNotifyListeners();
  }

  // フィルタされたリストのソート
  void _sortFilteredList() {
    _filteredAnimeList.sort((a, b) {
      int compare = 0;
      switch (_sortOrder) {
        case SortOrder.tid:
          compare = int.parse(a['tid'].toString())
              .compareTo(int.parse(b['tid'].toString()));
          break;

        case SortOrder.year:
          int aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
          int bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
          int aMonth = int.tryParse(a['firstmonth'].toString()) ?? 0;
          int bMonth = int.tryParse(b['firstmonth'].toString()) ?? 0;

          if (aYear != bYear) {
            compare = aYear.compareTo(bYear);
          } else {
            compare = aMonth.compareTo(bMonth);
          }
          break;

        case SortOrder.name:
          compare = a['title'].toString().compareTo(b['title'].toString());
          break;
      }
      return _isAscending ? compare : -compare;
    });
  }

  //ソート処理(昇順・降順対応)
  void sortAnimeList() {
    _animeList.sort((a, b) {
      int compare = 0;
      switch (_sortOrder) {
        case SortOrder.tid:
          compare = int.parse(a['tid'].toString())
              .compareTo(int.parse(b['tid'].toString()));
          break;

        case SortOrder.year:
          //年と月の両方に対応
          int aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
          int bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
          int aMonth = int.tryParse(a['firstmonth'].toString()) ?? 0;
          int bMonth = int.tryParse(b['firstmonth'].toString()) ?? 0;

          if (aYear != bYear) {
            compare = aYear.compareTo(bYear); // まず年で比較
          } else {
            compare = aMonth.compareTo(bMonth); // 同じ年なら月で比較
          }
          break;

        case SortOrder.name:
          compare =
              a['title'].toString().compareTo(b['title'].toString()); // 文字列昇順
          break;
      }
      return _isAscending ? compare : -compare; //昇順・降順の切り替え
    });
    
    // 検索中の場合は、フィルタされたリストもソートする
    if (_searchQuery.isNotEmpty) {
      _sortFilteredList();
    }
    
    _safeNotifyListeners();
  }

  // 安全にnotifyListenersを呼ぶためのヘルパーメソッド
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> initOfflineModeAndLoadCache() async {
    // await FirebaseFirestore.instance.disableNetwork();
    final cacheSnapshot = await FirebaseFirestore.instance
        .collection('titles')
        .get(const GetOptions(source: Source.cache))
        .catchError((e) {
      debugPrint('Error reading cache: $e');
      return null;
    });

    if (cacheSnapshot != null) {
      final List<Map<String, dynamic>> cacheList =
          cacheSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'].toString(), // TIDをString型に変換
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      _animeList = cacheList;
      sortAnimeList(); //ソートの適用
      _safeNotifyListeners();
    }
  }

  Future<void> fetchFromServer() async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      await FirebaseFirestore.instance.enableNetwork();
      final serverSnapshot = await FirebaseFirestore.instance
          .collection('titles')
          .get(const GetOptions(source: Source.server));

      final List<Map<String, dynamic>> newList = serverSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'tid': doc['TID'].toString(), // TIDをString型に変換
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      // ▼ ここでサーバーから取得したリストをソートする ▼
      _animeList = newList;
      sortAnimeList(); //ソートの適用

      // 選択されたアニメの情報を取得
      await loadSelectedAnime();

      // await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      debugPrint('Error fetching from server: $e');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> selectAnime(String tid) async {
    _selectedAnime.add(tid);
    _safeNotifyListeners();
  }

  Future<void> deselectAnime(String tid) async {
    _selectedAnime.remove(tid);
    _safeNotifyListeners();
  }

  Future<void> saveSelectedAnime() async {
    final user = FirebaseAuth.instance.currentUser;
    print('セーブ処理開始');
    if (user == null) {
      print('user is null');
      return;
    }

    // ■ オフラインモードから書き込み用にオンラインへ切り替え
    await FirebaseFirestore.instance.enableNetwork();

    try {
      final userId = user.uid;
      final List<WriteBatch> batches = [];
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchSize = 0;

      // Firestoreに選択されたアニメを保存（TID以外のデータも含む）
      for (var tid in _selectedAnime) {
        // _animeListから該当するanimeデータを探す
        final anime = _animeList.firstWhereOrNull(
          (element) => element['tid'] == tid,
        );

        if (anime != null) {
          final docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('selectedAnime')
              .doc(tid);
          // TIDのみならず、タイトルやその他の情報も保存する
          batch.set(docRef, {
            'tid': anime['tid'],
            'title': anime['title'],
            'titleyomi': anime['titleyomi'],
            'firstmonth': anime['firstmonth'],
            'firstyear': anime['firstyear'],
            'comment': anime['comment'],
          });
          batchSize++;
        } else {
          print('Warning: tid $tid に対応するanimeデータが見つかりません');
        }

        if (batchSize == 500) {
          batches.add(batch);
          batch = FirebaseFirestore.instance.batch();
          batchSize = 0;
        }
      }

      if (batchSize > 0) {
        batches.add(batch);
      }

      print('セーブ処理中');
      for (var b in batches) {
        await b.commit(); // ← サーバーとやり取りするためオンライン必須
      }
      
      // 登録済みアニメのセットを更新
      _registeredAnime.addAll(_selectedAnime);
      
      // 一時選択をクリア
      _selectedAnime.clear();
      
      print('セーブ処理完了');
    } catch (e) {
      print('セーブ処理中にエラーが発生しました: $e');
    } finally {
      // ■ 書き込みが終わったら再びオフラインへ切り替え
      // await FirebaseFirestore.instance.disableNetwork();
      _safeNotifyListeners();
    }
  }

  Future<void> deleteSelectedAnime() async {
    final user = FirebaseAuth.instance.currentUser;
    print('削除処理開始');
    if (user == null) {
      print('user is null');
      return;
    }

    // ■ オフラインモードから書き込み用にオンラインへ切り替え
    await FirebaseFirestore.instance.enableNetwork();

    try {
      final userId = user.uid;
      final List<WriteBatch> batches = [];
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchSize = 0;

      // 選択されたアニメを削除
      for (var tid in _selectedAnime) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selectedAnime')
            .doc(tid);
        batch.delete(docRef);
        batchSize++;

        if (batchSize == 500) {
          batches.add(batch);
          batch = FirebaseFirestore.instance.batch();
          batchSize = 0;
        }
      }

      if (batchSize > 0) {
        batches.add(batch);
      }

      // 実際に削除をコミット
      for (var b in batches) {
        await b.commit(); // ← サーバーとのやり取りを行うのでオンライン必須
      }

      // 登録済みアニメのセットから削除
      _registeredAnime.removeAll(_selectedAnime);
      
      // ローカルで選択されたアニメのセットをクリア
      _selectedAnime.clear();
      
      print('削除処理完了');
    } catch (e) {
      print('削除処理中にエラーが発生しました: $e');
    } finally {
      // ■ 削除が終わったら再びオフラインへ切り替え
      // await FirebaseFirestore.instance.disableNetwork();
      _safeNotifyListeners();
    }
  }

  Future<void> loadSelectedAnime() async {
    final user = FirebaseAuth.instance.currentUser;
    print('ロード処理開始');
    if (user != null) {
      final userId = user.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .get();

      // 登録済みアニメのセットを更新
      _registeredAnime = snapshot.docs.map((doc) => doc.id).toSet();
      
      // 一時選択をクリア（登録済みのものは選択状態から外す）
      _selectedAnime.clear();
      
      _safeNotifyListeners();
      print('ロード処理完了');
    } else {
      print('user is null');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
