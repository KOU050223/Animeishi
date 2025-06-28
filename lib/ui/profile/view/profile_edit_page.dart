import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math' show cos, sin;


class ProfileEditPage extends StatefulWidget {
  final String username;
  final List<String> selectedGenres;
  final String email;

  ProfileEditPage({
    required this.username,
    required this.selectedGenres,
    required this.email,
  });

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> with TickerProviderStateMixin {
  late String _username;
  late List<String> _selectedGenres;
  late String _email;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  
  // カスタマイズ要素
  int _selectedTheme = 0;
  int _selectedAvatar = 0;
  int _selectedPattern = 0;
  int _selectedCardStyle = 0;
  String _favoriteQuote = '';
  String _profileImageUrl = '';
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;
  final TextEditingController _quoteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  // デコレーション要素
  List<Map<String, dynamic>> _selectedStickers = [];
  int _selectedBorder = 0;
  double _cardOpacity = 1.0;
  
  // アニメーション
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _allGenres = [
    'SF/ファンタジー',
    'ロボット/メカ',
    'アクション/バトル',
    'コメディ/ギャグ',
    '恋愛/ラブコメ',
    '日常/ほのぼの',
    'スポーツ/競技',
    'ホラー/サスペンス/推理',
    '歴史/戦記',
    '戦争/ミリタリー',
    'ドラマ/青春',
    'キッズ/ファミリー',
    'ショート',
    '2.5次元舞台',
    'ライブ/ラジオ/etc',
  ];

  // カラーテーマ
  final List<Map<String, dynamic>> _colorThemes = [
    {
      'name': 'オーロラ',
      'gradient': <Color>[Color(0xFF667eea), Color(0xFF764ba2)],
      'accent': Color(0xFF667eea),
    },
    {
      'name': 'サンセット',
      'gradient': <Color>[Color(0xFFf093fb), Color(0xFFf5576c)],
      'accent': Color(0xFFf093fb),
    },
    {
      'name': 'オーシャン',
      'gradient': <Color>[Color(0xFF4facfe), Color(0xFF00f2fe)],
      'accent': Color(0xFF4facfe),
    },
    {
      'name': 'フォレスト',
      'gradient': <Color>[Color(0xFF43e97b), Color(0xFF38f9d7)],
      'accent': Color(0xFF43e97b),
    },
    {
      'name': 'ラベンダー',
      'gradient': <Color>[Color(0xFFa8edea), Color(0xFFfed6e3)],
      'accent': Color(0xFFa8edea),
    },
    {
      'name': 'ゴールド',
      'gradient': <Color>[Color(0xFFffecd2), Color(0xFFfcb69f)],
      'accent': Color(0xFFffecd2),
    },
  ];

  // アバターアイコン
  final List<IconData> _avatarIcons = [
    Icons.person,
    Icons.sentiment_very_satisfied,
    Icons.pets,
    Icons.star,
    Icons.favorite,
    Icons.music_note,
    Icons.movie,
    Icons.gamepad,
    Icons.palette,
    Icons.auto_awesome,
  ];

  // パターン
  final List<String> _patterns = [
    'シンプル',
    'ドット',
    'ストライプ',
    'グラデーション',
    'キラキラ',
    'ハート',
  ];

  // 名刺スタイル
  final List<Map<String, dynamic>> _cardStyles = [
    {'name': 'クラシック', 'icon': Icons.credit_card},
    {'name': 'モダン', 'icon': Icons.style},
    {'name': 'エレガント', 'icon': Icons.auto_awesome},
    {'name': 'カジュアル', 'icon': Icons.emoji_emotions},
    {'name': 'プロフェッショナル', 'icon': Icons.business_center},
    {'name': 'アニメ風', 'icon': Icons.animation},
  ];

  // ボーダー
  final List<String> _borders = [
    'なし',
    'シンプル',
    'ダブル',
    'ドット',
    'グラデーション',
    'キラキラ',
  ];

  // ステッカー
  final List<Map<String, dynamic>> _availableStickers = [
    {'icon': '⭐', 'name': 'スター'},
    {'icon': '💖', 'name': 'ハート'},
    {'icon': '🌸', 'name': 'サクラ'},
    {'icon': '🎵', 'name': 'ミュージック'},
    {'icon': '🎮', 'name': 'ゲーム'},
    {'icon': '📺', 'name': 'アニメ'},
    {'icon': '🍀', 'name': 'クローバー'},
    {'icon': '🌟', 'name': 'キラキラ'},
    {'icon': '🎭', 'name': 'マスク'},
    {'icon': '🎨', 'name': 'アート'},
    {'icon': '⚡', 'name': 'ライトニング'},
    {'icon': '🔥', 'name': 'ファイア'},
  ];

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    _selectedGenres = List.from(widget.selectedGenres);
    _email = widget.email;
    _emailController.text = _email;
    _usernameController.text = _username;
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _loadUserCustomization();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadUserCustomization() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _selectedTheme = data['cardTheme'] ?? 0;
            _selectedAvatar = data['cardAvatar'] ?? 0;
            _selectedPattern = data['cardPattern'] ?? 0;
            _selectedCardStyle = data['cardStyle'] ?? 0;
            _selectedBorder = data['cardBorder'] ?? 0;
            _cardOpacity = data['cardOpacity'] ?? 1.0;
            _favoriteQuote = data['favoriteQuote'] ?? '';
            _profileImageUrl = data['profileImageUrl'] ?? '';
            _quoteController.text = _favoriteQuote;
            _bioController.text = data['bio'] ?? '';
            _selectedStickers = List<Map<String, dynamic>>.from(data['stickers'] ?? []);
          });
        }
      } catch (e) {
        print('Error loading customization: $e');
      }
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Web用の処理
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // モバイル用の処理
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      if (kIsWeb) {
        // Web環境でのフォールバック
        _showWebImagePickerDialog();
      } else {
        _showErrorSnackBar('画像の選択に失敗しました: $e');
      }
    }
  }

  void _showWebImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: _colorThemes[_selectedTheme]['accent']),
            SizedBox(width: 8),
            Text('画像選択について'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Web環境では画像選択機能に制限があります。'),
            SizedBox(height: 12),
            Text('以下の方法をお試しください：'),
            SizedBox(height: 8),
            Text('• ブラウザを更新してから再度お試しください'),
            Text('• 別のブラウザをご利用ください'),
            Text('• モバイルアプリをご利用ください'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _tryImagePickerAgain();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorThemes[_selectedTheme]['accent'],
              foregroundColor: Colors.white,
            ),
            child: Text('再試行'),
          ),
        ],
      ),
    );
  }

  Future<void> _tryImagePickerAgain() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('再試行に失敗しました。別のブラウザまたはモバイルアプリをお試しください。');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // Web用の処理
          final bytes = await image.readAsBytes();
          setState(() {
            _webImage = bytes;
            _selectedImage = null;
          });
        } else {
          // モバイル用の処理
          setState(() {
            _selectedImage = File(image.path);
            _webImage = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('画像の選択に失敗しました: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null && _webImage == null) return _profileImageUrl;
    
    try {
      setState(() {
        _isUploading = true;
      });
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      
      String downloadUrl;
      
      if (kIsWeb && _webImage != null) {
        // Web用のアップロード
        await ref.putData(_webImage!);
        downloadUrl = await ref.getDownloadURL();
      } else if (_selectedImage != null) {
        // モバイル用のアップロード
        await ref.putFile(_selectedImage!);
        downloadUrl = await ref.getDownloadURL();
      } else {
        return _profileImageUrl;
      }
      
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('画像のアップロードに失敗しました'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return null;
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // メールアドレスの更新
        if (_emailController.text != _email) {
          await user.updateEmail(_emailController.text);
        }

        await user.updateProfile(displayName: _usernameController.text);

        // 画像をアップロード
        final imageUrl = await _uploadImage();

        // Firestoreにカスタマイズ情報を保存
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'username': _usernameController.text,
          'selectedGenres': _selectedGenres,
          'cardTheme': _selectedTheme,
          'cardAvatar': _selectedAvatar,
          'cardPattern': _selectedPattern,
          'cardStyle': _selectedCardStyle,
          'cardBorder': _selectedBorder,
          'cardOpacity': _cardOpacity,
          'favoriteQuote': _quoteController.text,
          'bio': _bioController.text,
          'profileImageUrl': imageUrl ?? _profileImageUrl,
          'stickers': _selectedStickers,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        Navigator.pop(context, {
          'username': _usernameController.text,
          'selectedGenres': _selectedGenres,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('アニ名刺が保存されました！'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('保存に失敗しました'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD6BCFA),
              Color(0xFFBFDBFE),
              Color(0xFFFBCFE8),
              Color(0xFFD1FAE5),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: [
                  // カスタムAppBar
                  _buildCustomAppBar(),
                  
                  // 名刺プレビュー
                  SliverToBoxAdapter(
                    child: _buildCardPreview(),
                  ),
                  
                  // カスタマイズセクション
                  SliverToBoxAdapter(
                    child: _buildCustomizationSections(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF667eea),
              size: 20,
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _updateProfile,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'アニ名刺エディター',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: Color(0xFF2D3748),
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'プレビュー',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildAnimeCard(),
        ],
      ),
    );
  }

  Widget _buildAnimeCard() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: (_colorThemes[_selectedTheme]['gradient'] as List<Color>).map((color) => 
            color.withOpacity(_cardOpacity)).toList(),
        ),
        borderRadius: BorderRadius.circular(_getCardBorderRadius()),
        border: _buildCardBorder(),
        boxShadow: [
          BoxShadow(
            color: _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // パターン背景
          if (_selectedPattern > 0) _buildPatternOverlay(),
          
          // カード内容
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                  Row(
                    children: [
                      // アバター
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: _webImage != null
                              ? Image.memory(
                                  _webImage!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                              : _selectedImage != null
                                  ? Image.file(
                                      _selectedImage!,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    )
                                  : _profileImageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: _profileImageUrl,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.white.withOpacity(0.3),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          _avatarIcons[_selectedAvatar],
                                          color: Colors.white,
                                          size: 30,
                                        ),
                        ),
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _usernameController.text.isEmpty ? 'ユーザー名' : _usernameController.text,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_bioController.text.isNotEmpty)
                            Text(
                              _bioController.text,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Spacer(),
                
                // 好きなジャンル
                if (_selectedGenres.isNotEmpty) ...[
                  Text(
                    '好きなジャンル',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _selectedGenres.take(3).map((genre) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                
                // お気に入りの言葉
                if (_quoteController.text.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      '"${_quoteController.text}"',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // ステッカー表示
          ..._selectedStickers.map((sticker) => Positioned(
            left: sticker['x'] * 200,
            top: sticker['y'] * 180,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                sticker['icon'],
                style: TextStyle(fontSize: 16),
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildPatternOverlay() {
    switch (_selectedPattern) {
      case 1: // ドット
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: _generateDotPattern(),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
        );
      case 2: // ストライプ
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: [0.0, 0.25, 0.5, 0.75],
            ),
          ),
        );
      case 4: // キラキラ
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: SparklesPainter(),
            size: Size.infinite,
          ),
        );
      case 5: // ハート
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: HeartsPainter(),
            size: Size.infinite,
          ),
        );
      default:
        return Container();
    }
  }

  ImageProvider _generateDotPattern() {
    // 簡単なドットパターンを生成（実際の実装では画像アセットを使用）
    return NetworkImage('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAiIGhlaWdodD0iMjAiIHZpZXdCb3g9IjAgMCAyMCAyMCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPGNpcmNsZSBjeD0iMTAiIGN5PSIxMCIgcj0iMiIgZmlsbD0id2hpdGUiIGZpbGwtb3BhY2l0eT0iMC4yIi8+Cjwvc3ZnPgo=');
  }

  double _getCardBorderRadius() {
    switch (_selectedCardStyle) {
      case 0: return 20; // クラシック
      case 1: return 8;  // モダン
      case 2: return 30; // エレガント
      case 3: return 15; // カジュアル
      case 4: return 5;  // プロフェッショナル
      case 5: return 25; // アニメ風
      default: return 20;
    }
  }

  Border? _buildCardBorder() {
    if (_selectedBorder == 0) return null;
    
    switch (_selectedBorder) {
      case 1: // シンプル
        return Border.all(color: Colors.white.withOpacity(0.5), width: 2);
      case 2: // ダブル
        return Border.all(color: Colors.white.withOpacity(0.7), width: 3);
      case 3: // ドット
        return Border.all(color: Colors.white.withOpacity(0.6), width: 2);
      case 4: // グラデーション
        return Border.all(color: Colors.white.withOpacity(0.8), width: 2);
      case 5: // キラキラ
        return Border.all(color: Colors.white.withOpacity(0.9), width: 3);
      default:
        return null;
    }
  }

  Widget _buildCustomizationSections() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildBasicInfoSection(),
          SizedBox(height: 20),
          _buildPhotoSection(),
          SizedBox(height: 20),
          _buildCardStyleSection(),
          SizedBox(height: 20),
          _buildThemeSection(),
          SizedBox(height: 20),
          _buildAvatarSection(),
          SizedBox(height: 20),
          _buildPatternSection(),
          SizedBox(height: 20),
          _buildBorderSection(),
          SizedBox(height: 20),
          _buildOpacitySection(),
          SizedBox(height: 20),
          _buildStickerSection(),
          SizedBox(height: 20),
          _buildGenreSection(),
          SizedBox(height: 20),
          _buildQuoteSection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '基本情報',
      icon: Icons.person_outline,
      children: [
        _buildTextField(
          controller: _usernameController,
          label: 'ユーザーネーム',
          hint: 'あなたの名前を入力',
          icon: Icons.badge,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: 'ひとこと',
          hint: '自己紹介やお気に入りの言葉',
          icon: Icons.chat_bubble_outline,
          maxLines: 2,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'メールアドレス',
          hint: 'メールアドレスを入力',
          icon: Icons.email_outlined,
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return _buildSection(
      title: 'プロフィール写真',
      icon: Icons.photo_camera,
      children: [
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(37),
                child: _webImage != null
                    ? Image.memory(_webImage!, fit: BoxFit.cover)
                    : _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : _profileImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: _profileImageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : () => _pickImageFromSource(ImageSource.gallery),
                          icon: _isUploading 
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.photo_library),
                          label: Text(_isUploading ? 'アップロード中...' : 'ギャラリー'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorThemes[_selectedTheme]['accent'],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      if (!kIsWeb) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isUploading ? null : () => _pickImageFromSource(ImageSource.camera),
                            icon: Icon(Icons.camera_alt),
                            label: Text('カメラ'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _colorThemes[_selectedTheme]['accent'].withOpacity(0.8),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_selectedImage != null || _webImage != null || _profileImageUrl.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _webImage = null;
                          _profileImageUrl = '';
                        });
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('削除', style: TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardStyleSection() {
    return _buildSection(
      title: '名刺スタイル',
      icon: Icons.style,
      children: [
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cardStyles.length,
            itemBuilder: (context, index) {
              final style = _cardStyles[index];
              final isSelected = _selectedCardStyle == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCardStyle = index;
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>)
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.white 
                          : _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        style['icon'],
                        color: isSelected ? Colors.white : _colorThemes[_selectedTheme]['accent'],
                        size: 24,
                      ),
                      SizedBox(height: 8),
                      Text(
                        style['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF2D3748),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return _buildSection(
      title: 'カラーテーマ',
      icon: Icons.palette_outlined,
      children: [
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colorThemes.length,
            itemBuilder: (context, index) {
              final theme = _colorThemes[index];
              final isSelected = _selectedTheme == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTheme = index;
                  });
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: theme['gradient'] as List<Color>),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme['accent'].withOpacity(0.3),
                        blurRadius: isSelected ? 12 : 6,
                        offset: Offset(0, isSelected ? 6 : 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected)
                        Icon(Icons.check_circle, color: Colors.white, size: 24),
                      SizedBox(height: 4),
                      Text(
                        theme['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return _buildSection(
      title: 'アバター',
      icon: Icons.face,
      children: [
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarIcons.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAvatar == index;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAvatar = index;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected 
                          ? _colorThemes[_selectedTheme]['gradient'] as List<Color>
                          : [Colors.grey[300]!, Colors.grey[400]!],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected 
                            ? _colorThemes[_selectedTheme]['accent'] 
                            : Colors.grey).withOpacity(0.3),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, isSelected ? 4 : 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _avatarIcons[index],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPatternSection() {
    return _buildSection(
      title: 'パターン',
      icon: Icons.texture,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _patterns.asMap().entries.map((entry) {
            final index = entry.key;
            final pattern = entry.value;
            final isSelected = _selectedPattern == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPattern = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>)
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white 
                        : _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  pattern,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    return _buildSection(
      title: '好きなジャンル',
      icon: Icons.category_outlined,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _allGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGenres.remove(genre);
                  } else {
                    _selectedGenres.add(genre);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>)
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white 
                        : _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  genre,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBorderSection() {
    return _buildSection(
      title: 'ボーダー',
      icon: Icons.border_style,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _borders.asMap().entries.map((entry) {
            final index = entry.key;
            final border = entry.value;
            final isSelected = _selectedBorder == index;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedBorder = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>)
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white 
                        : _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  border,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF2D3748),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpacitySection() {
    return _buildSection(
      title: '透明度',
      icon: Icons.opacity,
      children: [
        Row(
          children: [
            Icon(Icons.opacity, color: _colorThemes[_selectedTheme]['accent']),
            Expanded(
              child: Slider(
                value: _cardOpacity,
                min: 0.3,
                max: 1.0,
                divisions: 7,
                activeColor: _colorThemes[_selectedTheme]['accent'],
                onChanged: (value) {
                  setState(() {
                    _cardOpacity = value;
                  });
                },
              ),
            ),
            Text(
              '${(_cardOpacity * 100).round()}%',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _colorThemes[_selectedTheme]['accent'],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickerSection() {
    return _buildSection(
      title: 'ステッカー',
      icon: Icons.emoji_emotions,
      children: [
        Text(
          '名刺に追加するステッカーを選択',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableStickers.map((sticker) {
            final isSelected = _selectedStickers.any((s) => s['icon'] == sticker['icon']);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedStickers.removeWhere((s) => s['icon'] == sticker['icon']);
                  } else if (_selectedStickers.length < 5) {
                    _selectedStickers.add({
                      'icon': sticker['icon'],
                      'name': sticker['name'],
                      'x': 0.8,
                      'y': 0.2,
                    });
                  }
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? LinearGradient(colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>)
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                        ? Colors.white 
                        : _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    sticker['icon'],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedStickers.isNotEmpty) ...[
          SizedBox(height: 12),
          Text(
            '選択中: ${_selectedStickers.map((s) => s['icon']).join(' ')}',
            style: TextStyle(
              fontSize: 12,
              color: _colorThemes[_selectedTheme]['accent'],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildQuoteSection() {
    return _buildSection(
      title: 'お気に入りの言葉',
      icon: Icons.format_quote,
      children: [
        _buildTextField(
          controller: _quoteController,
          label: 'お気に入りの言葉',
          hint: 'アニメの名言や好きな言葉を入力',
          icon: Icons.favorite_border,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _colorThemes[_selectedTheme]['gradient'] as List<Color>,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _colorThemes[_selectedTheme]['accent'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: _colorThemes[_selectedTheme]['accent']),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: _colorThemes[_selectedTheme]['accent'],
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        style: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// カスタムペインター
class SparklesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // キラキラを描画
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      _drawStar(canvas, paint, Offset(x, y), 3);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159) / 5;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HeartsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // ハートを描画
    for (int i = 0; i < 15; i++) {
      final x = (i * 41) % size.width;
      final y = (i * 29) % size.height;
      _drawHeart(canvas, paint, Offset(x, y), 4);
    }
  }

  void _drawHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size);
    path.cubicTo(
      center.dx - size, center.dy - size / 2,
      center.dx - size * 2, center.dy - size,
      center.dx, center.dy - size / 2,
    );
    path.cubicTo(
      center.dx + size * 2, center.dy - size,
      center.dx + size, center.dy - size / 2,
      center.dx, center.dy + size,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
