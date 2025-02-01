import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SortOrder {tid,year,name}

class AnimeListViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = false;
  Set<String> _selectedAnime = {}; // 選択されたアニメのTIDを保持するセット
  SortOrder _sortOrder = SortOrder.tid; //デフォルトはtid順
  bool _isAscending = true; //デフォルトは昇順

  List<Map<String, dynamic>> get animeList => _animeList;
  bool get isLoading => _isLoading;
  Set<String> get selectedAnime => _selectedAnime; // 選択されたアニメのTIDを取得するゲッター
  SortOrder get sortOrder => _sortOrder; //ソート順を取得するゲッター
  bool get isAscending => _isAscending; //昇順 or 降順を取得
  
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

  void sortAnimeList() {
    _animeList.sort((a, b) {
      int compare = 0;
      switch (_sortOrder) {
        case SortOrder.tid:
          final aTid = int.tryParse(a['tid'].toString()) ?? 0;
          final bTid = int.tryParse(b['tid'].toString()) ?? 0;
          compare = aTid.compareTo(bTid);
          break;
        case SortOrder.year:
          final aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
          final bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
          compare = aYear.compareTo(bYear);
          break;
        case SortOrder.name:
          compare = a['title'].toString().compareTo(b['title'].toString()); // 文字列昇順
          break;
      }
      return _isAscending ? compare : -compare; //昇順・降順の切り替え
    });
    notifyListeners();
  }

  Future<void> initOfflineModeAndLoadCache() async {
    await FirebaseFirestore.instance.disableNetwork();
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
      notifyListeners(); 
    }
  }

  Future<void> fetchFromServer() async {
    _isLoading = true;
    notifyListeners();

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

      await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      debugPrint('Error fetching from server: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAnime(String tid) async {
    _selectedAnime.add(tid);
    notifyListeners();
  }

  Future<void> deselectAnime(String tid) async {
    _selectedAnime.remove(tid);
    notifyListeners();
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
      // ▼ 以下はこれまでのバッチ書き込みロジックをそのまま使用
      final userId = user.uid;
      final List<WriteBatch> batches = [];
      WriteBatch batch = FirebaseFirestore.instance.batch();
      int batchSize = 0;

      // Firestoreに選択されたアニメを保存
      for (var tid in _selectedAnime) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('selectedAnime')
            .doc(tid);
        batch.set(docRef, {'tid': tid});
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

      // Firestoreから削除されたアニメを削除
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .get();
      batch = FirebaseFirestore.instance.batch();
      batchSize = 0;

      for (var doc in snapshot.docs) {
        if (!_selectedAnime.contains(doc.id)) {
          batch.delete(doc.reference);
          batchSize++;

          if (batchSize == 500) {
            batches.add(batch);
            batch = FirebaseFirestore.instance.batch();
            batchSize = 0;
          }
        }
      }

      if (batchSize > 0) {
        batches.add(batch);
      }

      print('セーブ処理中');
      for (var b in batches) {
        await b.commit(); // ← サーバーとやり取りするためオンライン必須
      }
      print('セーブ処理完了');
    } catch (e) {
      print('セーブ処理中にエラーが発生しました: $e');
    } finally {
      // ■ 書き込みが終わったら再びオフラインへ切り替え
      await FirebaseFirestore.instance.disableNetwork();
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

      // ローカルで選択されたアニメのセットをクリア
      _selectedAnime.clear();
      notifyListeners();
      print('削除処理完了');
    } catch (e) {
      print('削除処理中にエラーが発生しました: $e');
    } finally {
      // ■ 削除が終わったら再びオフラインへ切り替え
      await FirebaseFirestore.instance.disableNetwork();
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

      _selectedAnime = snapshot.docs.map((doc) => doc.id).toSet();
      notifyListeners();
      print('ロード処理完了');
    } else {
      print('user is null');
    }
  }
}
