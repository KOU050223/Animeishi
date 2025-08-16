import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';
import 'package:animeishi/config/feature_flags.dart';

enum SortOrder { tid, year, name }

class AnimeListViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _animeList = [];
  List<Map<String, dynamic>> _filteredAnimeList = [];
  bool _isLoading = false;
  Set<String> _selectedAnime = {}; // 一時的に選択されたアニメのTIDを保持するセット
  Set<String> _registeredAnime = {}; // 登録済みアニメのTIDを保持するセット
  SortOrder _sortOrder = SortOrder.year; //デフォルトはyear順
  bool _isAscending = false; //デフォルトを降順
  bool _disposed = false; // dispose状態を追跡
  String _searchQuery = ''; // 検索クエリ

  List<Map<String, dynamic>> get animeList =>
      _filteredAnimeList.isNotEmpty || _searchQuery.isNotEmpty
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
    // 開発環境ではテストデータを使用
    if (FeatureFlags.enableTestDataCreation) {
      if (FeatureFlags.enableDebugLogs) {
        debugPrint('開発環境: キャッシュの代わりにテスト用データを使用します');
      }

      _animeList = _generateTestData();
      sortAnimeList();
      _safeNotifyListeners();
      return;
    }

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
    } else if (FeatureFlags.enableTestDataCreation) {
      // キャッシュが存在しない場合、開発環境ならテストデータを使用
      if (FeatureFlags.enableDebugLogs) {
        debugPrint('キャッシュが存在しないため、テスト用データを使用します');
      }
      _animeList = _generateTestData();
      sortAnimeList();
      _safeNotifyListeners();
    }
  }

  /// テスト用のアニメリストデータを生成（実際のTIDに準拠した内容）
  List<Map<String, dynamic>> _generateTestData() {
    return [
      {
        'id': '1',
        'tid': '1',
        'title': '魔法遣いに大切なこと',
        'titleyomi': 'まほうつかいにたいせつなこと',
        'firstmonth': '1',
        'firstyear': '2003',
        'comment': 'A magical realism anime',
      },
      {
        'id': '2',
        'tid': '2',
        'title': 'ソニックX',
        'titleyomi': 'ソニックエックス',
        'firstmonth': '4',
        'firstyear': '2003',
        'comment': 'A Sonic the Hedgehog anime',
      },
      {
        'id': '3',
        'tid': '3',
        'title': 'Attack on Titan',
        'titleyomi': '進撃の巨人',
        'firstmonth': '4',
        'firstyear': '2013',
        'comment': 'A dark fantasy anime',
      },
      {
        'id': '4',
        'tid': '4',
        'title': 'My Hero Academia',
        'titleyomi': '僕のヒーローアカデミア',
        'firstmonth': '4',
        'firstyear': '2016',
        'comment': 'A superhero anime',
      },
      {
        'id': '5',
        'tid': '5',
        'title': 'Demon Slayer',
        'titleyomi': '鬼滅の刃',
        'firstmonth': '4',
        'firstyear': '2019',
        'comment': 'A demon hunting anime',
      },
      {
        'id': '6',
        'tid': '6',
        'title': 'Fullmetal Alchemist',
        'titleyomi': '鋼の錬金術師',
        'firstmonth': '10',
        'firstyear': '2003',
        'comment': 'An alchemy adventure anime',
      },
      {
        'id': '7',
        'tid': '7',
        'title': 'Death Note',
        'titleyomi': 'デスノート',
        'firstmonth': '10',
        'firstyear': '2006',
        'comment': 'A psychological thriller anime',
      },
      {
        'id': '8',
        'tid': '8',
        'title': 'Sword Art Online',
        'titleyomi': 'ソードアート・オンライン',
        'firstmonth': '7',
        'firstyear': '2012',
        'comment': 'A virtual reality anime',
      },
      {
        'id': '9',
        'tid': '9',
        'title': 'Tokyo Ghoul',
        'titleyomi': '東京喰種',
        'firstmonth': '7',
        'firstyear': '2014',
        'comment': 'A dark fantasy anime',
      },
      {
        'id': '10',
        'tid': '10',
        'title': 'Fairy Tail',
        'titleyomi': 'フェアリーテイル',
        'firstmonth': '10',
        'firstyear': '2009',
        'comment': 'A magic adventure anime',
      },
      {
        'id': '11',
        'tid': '11',
        'title': 'Bleach',
        'titleyomi': 'ブリーチ',
        'firstmonth': '10',
        'firstyear': '2004',
        'comment': 'A soul reaper anime',
      },
      {
        'id': '12',
        'tid': '12',
        'title': 'Dragon Ball Z',
        'titleyomi': 'ドラゴンボールZ',
        'firstmonth': '4',
        'firstyear': '1989',
        'comment': 'A classic martial arts anime',
      },
      {
        'id': '13',
        'tid': '13',
        'title': 'Hunter x Hunter',
        'titleyomi': 'ハンター×ハンター',
        'firstmonth': '10',
        'firstyear': '1999',
        'comment': 'A hunter adventure anime',
      },
      {
        'id': '14',
        'tid': '14',
        'title': 'Black Clover',
        'titleyomi': 'ブラッククローバー',
        'firstmonth': '10',
        'firstyear': '2017',
        'comment': 'A magic fantasy anime',
      },
      {
        'id': '15',
        'tid': '15',
        'title': 'Jujutsu Kaisen',
        'titleyomi': '呪術廻戦',
        'firstmonth': '10',
        'firstyear': '2020',
        'comment': 'A supernatural action anime',
      },
      {
        'id': '16',
        'tid': '16',
        'title': 'Re:Zero',
        'titleyomi': 'Re:ゼロから始める異世界生活',
        'firstmonth': '4',
        'firstyear': '2016',
        'comment': 'A fantasy adventure anime',
      },
      {
        'id': '17',
        'tid': '17',
        'title': 'Steins;Gate',
        'titleyomi': 'シュタインズ・ゲート',
        'firstmonth': '4',
        'firstyear': '2011',
        'comment': 'A science fiction anime',
      },
      {
        'id': '18',
        'tid': '18',
        'title': 'Code Geass',
        'titleyomi': 'コードギアス',
        'firstmonth': '10',
        'firstyear': '2006',
        'comment': 'A mecha anime',
      },
      {
        'id': '19',
        'tid': '19',
        'title': 'Gintama',
        'titleyomi': '銀魂',
        'firstmonth': '4',
        'firstyear': '2006',
        'comment': 'A comedy action anime',
      },
      {
        'id': '20',
        'tid': '20',
        'title': 'One Punch Man',
        'titleyomi': 'ワンパンマン',
        'firstmonth': '10',
        'firstyear': '2015',
        'comment': 'A superhero parody anime',
      },
      {
        'id': '21',
        'tid': '21',
        'title': 'Mob Psycho 100',
        'titleyomi': 'モブサイコ100',
        'firstmonth': '7',
        'firstyear': '2016',
        'comment': 'A supernatural comedy anime',
      },
      {
        'id': '22',
        'tid': '22',
        'title': 'The Promised Neverland',
        'titleyomi': '約束のネバーランド',
        'firstmonth': '1',
        'firstyear': '2019',
        'comment': 'A dark fantasy thriller anime',
      },
      {
        'id': '23',
        'tid': '23',
        'title': 'Dr. Stone',
        'titleyomi': 'ドクターストーン',
        'firstmonth': '7',
        'firstyear': '2019',
        'comment': 'A science adventure anime',
      },
    ];
  }

  Future<void> fetchFromServer() async {
    _isLoading = true;
    _safeNotifyListeners();

    try {
      // 開発環境でのテストデータ使用判定
      if (FeatureFlags.enableTestDataCreation) {
        if (FeatureFlags.enableDebugLogs) {
          debugPrint('開発環境: テスト用アニメリストを使用します');
        }

        // テスト用データを使用
        _animeList = _generateTestData();
        sortAnimeList();

        // 選択されたアニメの情報を取得
        await loadSelectedAnime();

        if (FeatureFlags.enableDebugLogs) {
          debugPrint('テスト用データの読み込み完了: ${_animeList.length}件');
        }
        return;
      }

      // 本番環境: Firestoreからデータを取得
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

      // エラー時に開発環境ならテストデータをフォールバックとして使用
      if (FeatureFlags.enableTestDataCreation) {
        if (FeatureFlags.enableDebugLogs) {
          debugPrint('サーバーエラーのため、テスト用データを使用します');
        }
        _animeList = _generateTestData();
        sortAnimeList();
      }
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

    // オンラインへ切り替え
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
        await b.commit(); // サーバーとやり取りするためオンライン必須
      }

      // 登録済みアニメのセットを更新
      _registeredAnime.addAll(_selectedAnime);

      // 一時選択をクリア
      _selectedAnime.clear();

      print('セーブ処理完了');
    } catch (e) {
      print('セーブ処理中にエラーが発生しました: $e');
    } finally {
      // 書き込みが終わったら再びオフラインへ切り替え
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

  Future<void> removeAnime(String tid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('user is null');
      return;
    }

    await FirebaseFirestore.instance.enableNetwork();

    try {
      final userId = user.uid;
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('selectedAnime')
          .doc(tid);

      await docRef.delete();

      _registeredAnime.remove(tid);

      print('アニメ削除完了: $tid');
    } catch (e) {
      print('アニメ削除中にエラーが発生しました: $e');
    } finally {
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
