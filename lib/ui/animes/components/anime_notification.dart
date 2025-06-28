import 'package:flutter/material.dart';

class AnimeNotification {
  static OverlayEntry? _currentOverlay;

  static void showSuccess(BuildContext context, String message, {String? subtitle}) {
    _showNotification(
      context,
      message: message,
      subtitle: subtitle,
      icon: Icons.check_circle_rounded,
      gradientColors: [
        Color(0xFF48BB78),
        Color(0xFF38A169),
      ],
      iconColor: Colors.white,
    );
  }

  static void showError(BuildContext context, String message, {String? subtitle}) {
    _showNotification(
      context,
      message: message,
      subtitle: subtitle,
      icon: Icons.error_rounded,
      gradientColors: [
        Color(0xFFf093fb),
        Color(0xFFf5576c),
      ],
      iconColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message, {String? subtitle}) {
    _showNotification(
      context,
      message: message,
      subtitle: subtitle,
      icon: Icons.info_rounded,
      gradientColors: [
        Color(0xFF667eea),
        Color(0xFF764ba2),
      ],
      iconColor: Colors.white,
    );
  }

  static void _showNotification(
    BuildContext context, {
    required String message,
    String? subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconColor,
  }) {
    // 既存の通知を削除
    _currentOverlay?.remove();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        subtitle: subtitle,
        icon: icon,
        gradientColors: gradientColors,
        iconColor: iconColor,
        onDismiss: () {
          overlayEntry.remove();
          _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // 4秒後に自動削除
    Future.delayed(Duration(seconds: 4), () {
      if (_currentOverlay == overlayEntry) {
        overlayEntry.remove();
        _currentOverlay = null;
      }
    });
  }

  static void dismiss() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconColor;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.iconColor,
    required this.onDismiss,
  });

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    // アニメーション開始
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _slideController.reverse();
    await _fadeController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 20,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth - 40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientColors[0].withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // 背景の装飾パターン
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -30,
                        left: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),

                      // メインコンテンツ
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // アイコン
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.iconColor,
                                size: 26,
                              ),
                            ),

                            SizedBox(width: 16),

                            // テキスト部分
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (widget.subtitle != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      widget.subtitle!,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            SizedBox(width: 12),

                            // 閉じるボタン
                            GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 