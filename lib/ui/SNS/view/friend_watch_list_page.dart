import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animeishi/ui/watch/view/watch_anime.dart';

enum SortOrder { ascending, descending }

class FriendWatchListPage extends StatefulWidget {
  final String userId;

  FriendWatchListPage({required this.userId});

  @override
  _FriendWatchListPageState createState() => _FriendWatchListPageState();
}

class _FriendWatchListPageState extends State<FriendWatchListPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _animeList = [];
  Set<String> _selectedAnime = {}; 
  SortOrder _sortOrder = SortOrder.descending; // デフォルトは降順

  @override
  void initState() {
    super.initState();
    _fetchSelectedAnime();
  }

  Future<void> _fetchSelectedAnime() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('selectedAnime')
          .withConverter<String>(
            fromFirestore: (doc, _) => doc.id,
            toFirestore: (id, _) => {},
          )
          .get();

      _selectedAnime = snapshot.docs.map((doc) => doc.data()).toSet();
      await _fetchAnimeDetails();
    } catch (e) {
      print('Failed to fetch selected anime: $e');
    }
  }

  Future<void> _fetchAnimeDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('titles')
          .where(FieldPath.documentId, whereIn: _selectedAnime.toList())
          .get();

      _animeList = snapshot.docs.map((doc) => {
        'id': doc.id,
        'tid': doc['TID'].toString(),
        'title': doc['Title'],
        'titleyomi': doc['TitleYomi'],
        'firstmonth': doc['FirstMonth'],
        'firstyear': doc['FirstYear'],
        'comment': doc['Comment'],
      }).toList();

      _sortAnimeList(); // **デフォルトで年代順にソート**
    } catch (e) {
      print('Failed to fetch anime details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// **年と月を参照してソート（デフォルト降順）**
  void _sortAnimeList() {
    _animeList.sort((a, b) {
      int aYear = int.tryParse(a['firstyear'].toString()) ?? 0;
      int bYear = int.tryParse(b['firstyear'].toString()) ?? 0;
      int aMonth = int.tryParse(a['firstmonth'].toString()) ?? 0;
      int bMonth = int.tryParse(b['firstmonth'].toString()) ?? 0;

      int compare = bYear.compareTo(aYear); // 年で降順
      if (compare == 0) {
        compare = bMonth.compareTo(aMonth); // 同じ年なら月で降順
      }

      return _sortOrder == SortOrder.descending ? compare : -compare;
    });

    setState(() {}); // ソート後に UI を更新
  }

  /// **ソートの昇順・降順を切り替え**
  void _toggleSortOrder() {
    setState(() {
      _sortOrder = _sortOrder == SortOrder.descending
          ? SortOrder.ascending
          : SortOrder.descending;
      _sortAnimeList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('フレンドの視聴履歴'),
        actions: [
          IconButton(
            icon: Icon(_sortOrder == SortOrder.descending
                ? Icons.arrow_downward
                : Icons.arrow_upward),
            onPressed: _toggleSortOrder,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _animeList.isEmpty
              ? Center(child: Text('視聴履歴はありません'))
              : ListView.builder(
                  itemCount: _animeList.length,
                  itemBuilder: (context, index) {
                    final anime = _animeList[index];
                    return ListTile(
                      title: Text('${anime['title']} (${anime['firstyear']}年 ${anime['firstmonth']}月)'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WatchAnimePage(anime: anime),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
