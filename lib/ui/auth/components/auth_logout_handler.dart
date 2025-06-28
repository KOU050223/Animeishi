import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthLogoutHandler {
  static void showLogoutDialog(
    BuildContext context,
    bool isLoggingOut,
    Function(bool) setLoggingOut,
  ) {
    if (isLoggingOut) return;
    
    showDialog(
      context: context,
      barrierDismissible: !isLoggingOut,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.95),
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade300,
                            Colors.red.shade500,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    
                    SizedBox(height: 24),
                    
                    Text(
                      'ログアウトしますか？',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    Text(
                      '現在のセッションを終了します',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: 32),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLoggingOut
                                    ? [Colors.grey.shade200, Colors.grey.shade300]
                                    : [Colors.grey.shade300, Colors.grey.shade400],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: isLoggingOut ? null : () => Navigator.of(context).pop(),
                                child: Center(
                                  child: Text(
                                    'キャンセル',
                                    style: TextStyle(
                                      color: isLoggingOut ? Colors.grey.shade500 : Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(width: 16),
                        
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isLoggingOut
                                    ? [Colors.grey.shade400, Colors.grey.shade500]
                                    : [Colors.red.shade400, Colors.red.shade600],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: isLoggingOut 
                                      ? Colors.grey.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: isLoggingOut ? null : () async {
                                  setState(() {
                                    isLoggingOut = true;
                                  });
                                  setLoggingOut(true);
                                  
                                  await performLogout(context);
                                  
                                  setState(() {
                                    isLoggingOut = false;
                                  });
                                  setLoggingOut(false);
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isLoggingOut) ...[
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                      Text(
                                        isLoggingOut ? 'ログアウト中...' : 'ログアウト',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> performLogout(BuildContext context) async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        Navigator.of(context).pop();
        _showMessage(context, '既にログアウトしています', Color(0xFF3182CE), Icons.info_outline);
        return;
      }
      
      await Future.delayed(Duration(milliseconds: 500));
      await FirebaseAuth.instance.signOut();
      
      Navigator.of(context).pop();
      _showMessage(context, 'ログアウトしました', Color(0xFF48BB78), Icons.check_circle_outline);
    } catch (e) {
      Navigator.of(context).pop();
      _showMessage(context, 'ログアウトに失敗しました', Colors.red.shade600, Icons.error_outline);
    }
  }

  static void _showMessage(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text(message, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Widget buildLogoutButton({
    required BuildContext context,
    required bool isLoggingOut,
    required Function(bool) setLoggingOut,
  }) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = currentUser != null;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: (isLoggingOut || !isLoggedIn) ? null : () => showLogoutDialog(context, isLoggingOut, setLoggingOut),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: (isLoggingOut || !isLoggedIn)
                    ? [Colors.grey.withOpacity(0.6), Colors.grey.withOpacity(0.4)]
                    : [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isLoggingOut || !isLoggedIn)
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: (isLoggingOut || !isLoggedIn)
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [Colors.red.shade300.withOpacity(0.8), Colors.red.shade400.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isLoggingOut
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          isLoggedIn ? Icons.logout_rounded : Icons.info_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                ),
                SizedBox(width: 12),
                Text(
                  isLoggingOut 
                      ? 'ログアウト中...' 
                      : isLoggedIn ? 'ログアウト' : 'ログアウト済み',
                  style: TextStyle(
                    color: (isLoggingOut || !isLoggedIn)
                        ? Color(0xFF718096)
                        : Color(0xFF2D3748),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 