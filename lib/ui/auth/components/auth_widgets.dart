import 'package:flutter/material.dart';

class AuthWidgets {
  static Widget buildAppIcon({required bool isSmallScreen}) {
    return Container(
      width: isSmallScreen ? 100 : 120,
      height: isSmallScreen ? 100 : 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea).withOpacity(0.8),
            Color(0xFF764ba2).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.25),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景の装飾
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          // メインアイコン
          Icon(
            Icons.credit_card,
            size: isSmallScreen ? 40 : 48,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  static Widget buildAppTitle({required bool isSmallScreen}) {
    return Column(
      children: [
        Text(
          'アニ名刺',
          style: TextStyle(
            fontSize: isSmallScreen ? 40 : 52,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3748),
            letterSpacing: 1.5,
            height: 1.1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'アニメ好きのための名刺交換アプリ',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget buildAnimatedButton({
    required String text,
    required IconData icon,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFD6BCFA), // ソフトパープル
            Color(0xFFBFDBFE), // ソフトブルー
            Color(0xFFFBCFE8), // ソフトピンク
            Color(0xFFD1FAE5), // ソフトグリーン
          ],
        ),
      ),
    );
  }

  // 統一された戻るボタン
  static Widget buildBackButton({required VoidCallback onPressed}) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
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
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 統一されたページタイトル
  static Widget buildPageTitle({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> iconColors,
    required bool isSmallScreen,
  }) {
    return Column(
      children: [
        // アイコン
        Container(
          width: isSmallScreen ? 80 : 100,
          height: isSmallScreen ? 80 : 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: iconColors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: iconColors[0].withOpacity(0.25),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? 35 : 45,
            color: Colors.white,
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 32),
        
        // タイトル
        Text(
          title,
          style: TextStyle(
            fontSize: isSmallScreen ? 32 : 40,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2D3748),
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        
        // サブタイトル
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            color: Color(0xFF718096),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 