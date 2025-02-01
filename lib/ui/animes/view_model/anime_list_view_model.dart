import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimeListViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _animeList = [];
  bool _isLoading = false;
  Set<String> _selectedAnime = {}; // 選択されたアニメのTIDを保持するセット

  List<Map<String, dynamic>> get animeList => _animeList;
  bool get isLoading => _isLoading;
  Set<String> get selectedAnime => _selectedAnime; // 選択されたアニメのTIDを取得するゲッター

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
          'tid': doc['TID'],
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      // ▼ ここでローカルのリストをソートする ▼
      cacheList.sort((a, b) {
        final aTid = int.tryParse(a['tid'].toString()) ?? 0;
        final bTid = int.tryParse(b['tid'].toString()) ?? 0;
        return aTid.compareTo(bTid); // 数値昇順
      });

      _animeList = cacheList;
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
          'tid': doc['TID'],
          'title': doc['Title'],
          'titleyomi': doc['TitleYomi'],
          'firstmonth': doc['FirstMonth'],
          'firstyear': doc['FirstYear'],
          'comment': doc['Comment'],
        };
      }).toList();

      // ▼ ここでサーバーから取得したリストをソートする ▼
      newList.sort((a, b) {
        final aTid = int.tryParse(a['tid'].toString()) ?? 0;
        final bTid = int.tryParse(b['tid'].toString()) ?? 0;
        return aTid.compareTo(bTid); // 数値昇順
      });

      _animeList = newList;
      await FirebaseFirestore.instance.disableNetwork();
    } catch (e) {
      debugPrint('Error fetching from server: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnime(String tid) {
    selectedAnime.add(tid);
    notifyListeners();
  }

  void deselectAnime(String tid) {
    selectedAnime.remove(tid);
    notifyListeners();
  }
}
