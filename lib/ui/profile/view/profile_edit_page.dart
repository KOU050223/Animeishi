import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';

// プロフィール関連のインポート
import '../model/profile_customization_data.dart';
import '../services/profile_image_service.dart';
import '../services/profile_data_service.dart';
import '../services/profile_validation_service.dart';

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
  final TextEditingController _quoteController = TextEditingController();
  
  // カスタマイゼーション設定
  ProfileCustomization _customization = ProfileCustomization();
  
  // 画像関連
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;
  
  // アニメーション
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
    _loadUserCustomization();
  }

  void _initializeData() {
    _username = widget.username;
    _selectedGenres = List.from(widget.selectedGenres);
    _email = widget.email;
    _emailController.text = _email;
    _usernameController.text = _username;
    
    // リアルタイム更新リスナー
    _usernameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
    _quoteController.addListener(() => setState(() {}));
  }

  void _setupAnimations() {
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
    
    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadUserCustomization() async {
    final customization = await ProfileDataService.loadUserCustomization();
    if (customization != null) {
      setState(() {
        _customization = customization;
        _quoteController.text = _customization.favoriteQuote;
        _bioController.text = _customization.bio;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    final result = await ProfileImageService.pickImage(source);
    
    if (result.success) {
      setState(() {
        _selectedImage = result.selectedImage;
        _webImage = result.webImage;
      });
    } else if (result.errorMessage != null) {
      ProfileValidationService.showErrorSnackBar(context, result.errorMessage!);
      if (kIsWeb) {
        ProfileImageService.showWebImagePickerDialog(context, () => _handleImageSelection(source));
      }
    }
  }

  Future<void> _saveProfile() async {
    // バリデーション
    final validation = ProfileValidationService.validateProfile(
      username: _usernameController.text,
      email: _emailController.text,
      bio: _bioController.text,
      quote: _quoteController.text,
      selectedGenres: _selectedGenres,
    );

    if (!validation.isValid) {
      ProfileValidationService.showValidationDialog(context, validation.errors);
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 画像アップロード
      String? imageUrl = _customization.profileImageUrl;
      if (_selectedImage != null || _webImage != null) {
        final uploadedUrl = await ProfileImageService.uploadImage(
          imageFile: _selectedImage,
          webImage: _webImage,
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      // カスタマイゼーションデータ更新
      final updatedCustomization = _customization.copyWith(
        favoriteQuote: _quoteController.text.trim(),
        profileImageUrl: imageUrl,
        bio: _bioController.text.trim(),
      );

      // プロフィール保存
      final success = await ProfileDataService.saveProfile(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        selectedGenres: _selectedGenres,
        customization: updatedCustomization,
      );

      if (success) {
        ProfileValidationService.showSuccessSnackBar(context, 'プロフィールを保存しました');
        Navigator.of(context).pop();
      } else {
        ProfileValidationService.showErrorSnackBar(context, 'プロフィールの保存に失敗しました');
      }
    } catch (e) {
      ProfileValidationService.showErrorSnackBar(context, 'エラーが発生しました: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ProfileCustomizationData.colorThemes[_customization.selectedTheme];
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: currentTheme['gradient'],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildProfileImageSection(),
                          SizedBox(height: 20),
                          _buildBasicInfoSection(),
                          SizedBox(height: 20),
                          _buildGenresSection(),
                          SizedBox(height: 20),
                          _buildCustomizationSection(),
                          SizedBox(height: 20),
                          _buildQuoteSection(),
                          SizedBox(height: 30),
                          _buildSaveButton(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'プロフィール編集',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return _buildSection(
      title: 'プロフィール画像',
      icon: Icons.account_circle,
      children: [
        Center(
          child: GestureDetector(
            onTap: () => ProfileImageService.showImageSourceDialog(context, _handleImageSelection),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Colors.grey[300],
                backgroundImage: _getProfileImage(),
                child: _getProfileImage() == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Text(
          'タップして画像を変更',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  ImageProvider? _getProfileImage() {
    if (_webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (_customization.profileImageUrl.isNotEmpty) {
      return CachedNetworkImageProvider(_customization.profileImageUrl);
    }
    return null;
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: '基本情報',
      icon: Icons.person,
      children: [
        _buildTextField(
          controller: _usernameController,
          label: 'ユーザー名',
          hint: 'あなたの名前を入力',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'メールアドレス',
          hint: 'your@email.com',
          icon: Icons.email_outlined,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: '自己紹介',
          hint: 'あなたについて教えてください',
          icon: Icons.description_outlined,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildGenresSection() {
    return _buildSection(
      title: '好きなジャンル',
      icon: Icons.favorite,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProfileCustomizationData.allGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGenres.add(genre);
                  } else {
                    _selectedGenres.remove(genre);
                  }
                });
              },
              selectedColor: ProfileCustomizationData.colorThemes[_customization.selectedTheme]['accent'].withOpacity(0.3),
              checkmarkColor: ProfileCustomizationData.colorThemes[_customization.selectedTheme]['accent'],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomizationSection() {
    return _buildSection(
      title: 'カスタマイゼーション',
      icon: Icons.palette,
      children: [
        _buildThemeSelector(),
        SizedBox(height: 16),
        _buildAvatarSelector(),
      ],
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'カラーテーマ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ProfileCustomizationData.colorThemes.length,
            separatorBuilder: (context, index) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final theme = ProfileCustomizationData.colorThemes[index];
              final isSelected = _customization.selectedTheme == index;
              
              return GestureDetector(
                onTap: () => setState(() {
                  _customization = _customization.copyWith(selectedTheme: index);
                }),
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: theme['gradient']),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'アバターアイコン',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ProfileCustomizationData.avatarIcons.length,
            separatorBuilder: (context, index) => SizedBox(width: 12),
            itemBuilder: (context, index) {
              final icon = ProfileCustomizationData.avatarIcons[index];
              final isSelected = _customization.selectedAvatar == index;
              
              return GestureDetector(
                onTap: () => setState(() {
                  _customization = _customization.copyWith(selectedAvatar: index);
                }),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? ProfileCustomizationData.editorAccentColor : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? ProfileCustomizationData.editorAccentColor : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : ProfileCustomizationData.editorAccentColor,
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

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: ProfileCustomizationData.editorAccentColor,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isUploading
            ? CircularProgressIndicator()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'プロフィールを保存',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
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
                    colors: [ProfileCustomizationData.editorPrimaryColor, ProfileCustomizationData.editorSecondaryColor],
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
          color: ProfileCustomizationData.editorAccentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: ProfileCustomizationData.editorAccentColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          labelStyle: TextStyle(
            color: ProfileCustomizationData.editorAccentColor,
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