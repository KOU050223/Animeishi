import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animeishi/config/feature_flags.dart';

void AnimeListFactory() async {
  // テストデータ作成機能が無効な場合は処理を中断
  if (!FeatureFlags.enableTestDataCreation) {
    if (FeatureFlags.enableDebugLogs) {
      print('テストデータ作成機能は本番環境では無効です');
    }
    return;
  }
  // Initialize Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Sample data to be added
  List<Map<String, dynamic>> animeList = [
    {
      'TID': '1',
      'Title': 'Naruto',
      'TitleYomi': 'ナルト',
      'FirstMonth': '10',
      'FirstYear': '2002',
      'Comment': 'A popular ninja anime',
    },
    {
      'TID': '2',
      'Title': 'One Piece',
      'TitleYomi': 'ワンピース',
      'FirstMonth': '10',
      'FirstYear': '1999',
      'Comment': 'A pirate adventure anime',
    },
    {
      'TID': '3',
      'Title': 'Attack on Titan',
      'TitleYomi': '進撃の巨人',
      'FirstMonth': '4',
      'FirstYear': '2013',
      'Comment': 'A dark fantasy anime',
    },
    {
      'TID': '4',
      'Title': 'My Hero Academia',
      'TitleYomi': '僕のヒーローアカデミア',
      'FirstMonth': '4',
      'FirstYear': '2016',
      'Comment': 'A superhero anime',
    },
    {
      'TID': '5',
      'Title': 'Demon Slayer',
      'TitleYomi': '鬼滅の刃',
      'FirstMonth': '4',
      'FirstYear': '2019',
      'Comment': 'A demon hunting anime',
    },
    {
      'TID': '6',
      'Title': 'Fullmetal Alchemist',
      'TitleYomi': '鋼の錬金術師',
      'FirstMonth': '10',
      'FirstYear': '2003',
      'Comment': 'An alchemy adventure anime',
    },
    {
      'TID': '7',
      'Title': 'Death Note',
      'TitleYomi': 'デスノート',
      'FirstMonth': '10',
      'FirstYear': '2006',
      'Comment': 'A psychological thriller anime',
    },
    {
      'TID': '8',
      'Title': 'Sword Art Online',
      'TitleYomi': 'ソードアート・オンライン',
      'FirstMonth': '7',
      'FirstYear': '2012',
      'Comment': 'A virtual reality anime',
    },
    {
      'TID': '9',
      'Title': 'Tokyo Ghoul',
      'TitleYomi': '東京喰種',
      'FirstMonth': '7',
      'FirstYear': '2014',
      'Comment': 'A dark fantasy anime',
    },
    {
      'TID': '10',
      'Title': 'Fairy Tail',
      'TitleYomi': 'フェアリーテイル',
      'FirstMonth': '10',
      'FirstYear': '2009',
      'Comment': 'A magic adventure anime',
    },
    {
      'TID': '11',
      'Title': 'Bleach',
      'TitleYomi': 'ブリーチ',
      'FirstMonth': '10',
      'FirstYear': '2004',
      'Comment': 'A soul reaper anime',
    },
    {
      'TID': '12',
      'Title': 'Dragon Ball Z',
      'TitleYomi': 'ドラゴンボールZ',
      'FirstMonth': '4',
      'FirstYear': '1989',
      'Comment': 'A classic martial arts anime',
    },
    {
      'TID': '13',
      'Title': 'Hunter x Hunter',
      'TitleYomi': 'ハンター×ハンター',
      'FirstMonth': '10',
      'FirstYear': '1999',
      'Comment': 'A hunter adventure anime',
    },
    {
      'TID': '14',
      'Title': 'Black Clover',
      'TitleYomi': 'ブラッククローバー',
      'FirstMonth': '10',
      'FirstYear': '2017',
      'Comment': 'A magic fantasy anime',
    },
    {
      'TID': '15',
      'Title': 'Jujutsu Kaisen',
      'TitleYomi': '呪術廻戦',
      'FirstMonth': '10',
      'FirstYear': '2020',
      'Comment': 'A supernatural action anime',
    },
    {
      'TID': '16',
      'Title': 'Re:Zero',
      'TitleYomi': 'Re:ゼロから始める異世界生活',
      'FirstMonth': '4',
      'FirstYear': '2016',
      'Comment': 'A fantasy adventure anime',
    },
    {
      'TID': '17',
      'Title': 'Steins;Gate',
      'TitleYomi': 'シュタインズ・ゲート',
      'FirstMonth': '4',
      'FirstYear': '2011',
      'Comment': 'A science fiction anime',
    },
    {
      'TID': '18',
      'Title': 'Code Geass',
      'TitleYomi': 'コードギアス',
      'FirstMonth': '10',
      'FirstYear': '2006',
      'Comment': 'A mecha anime',
    },
    {
      'TID': '19',
      'Title': 'Gintama',
      'TitleYomi': '銀魂',
      'FirstMonth': '4',
      'FirstYear': '2006',
      'Comment': 'A comedy action anime',
    },
    {
      'TID': '20',
      'Title': 'One Punch Man',
      'TitleYomi': 'ワンパンマン',
      'FirstMonth': '10',
      'FirstYear': '2015',
      'Comment': 'A superhero parody anime',
    },
    {
      'TID': '21',
      'Title': 'Mob Psycho 100',
      'TitleYomi': 'モブサイコ100',
      'FirstMonth': '7',
      'FirstYear': '2016',
      'Comment': 'A supernatural comedy anime',
    },
    {
      'TID': '22',
      'Title': 'The Promised Neverland',
      'TitleYomi': '約束のネバーランド',
      'FirstMonth': '1',
      'FirstYear': '2019',
      'Comment': 'A dark fantasy thriller anime',
    },
    {
      'TID': '23',
      'Title': 'Dr. Stone',
      'TitleYomi': 'ドクターストーン',
      'FirstMonth': '7',
      'FirstYear': '2019',
      'Comment': 'A science adventure anime',
    }
  ];

  if (FeatureFlags.enableDebugLogs) {
    print('Adding data to Firestore...');
  }
  // Add data to Firestore
  for (var anime in animeList) {
    await firestore.collection('titles').doc(anime['TID']).set(anime);
  }

  if (FeatureFlags.enableDebugLogs) {
    print('Data added to Firestore successfully.');
  }
}
