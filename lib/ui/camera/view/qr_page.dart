import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animeishi/ui/camera/view/scandata.dart';
import 'package:animeishi/ui/home/view/home_page.dart';
import 'package:animeishi/utils/error_handler.dart';
import 'package:animeishi/utils/validators.dart';

class ScannerWidget extends StatefulWidget {
  const ScannerWidget({super.key});

  @override
  State<ScannerWidget> createState() => _ScannerWidgetState();
}

class _ScannerWidgetState extends State<ScannerWidget>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();

  /// **Firestore にスキャン情報を保存する（検証強化版）**
  Future<void> saveUserIdToFirestore(String scannedData) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _showError(ErrorHandler.getQRErrorMessage('unauthenticated'));
        return;
      }

      // 1. QRコードデータの検証
      final userId = _extractUserIdFromQR(scannedData);
      if (userId == null) {
        _showError(ErrorHandler.getQRErrorMessage('invalid_format'));
        return;
      }

      // 2. ユーザーID形式の検証
      final validationError = Validators.validateUserId(userId);
      if (validationError != null) {
        _showError(validationError);
        return;
      }

      // 3. 自分自身のチェック
      if (currentUser.uid == userId) {
        _showError(ErrorHandler.getQRErrorMessage('self_scan'));
        return;
      }

      // 4. ユーザーの存在確認
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        _showError(ErrorHandler.getQRErrorMessage('user_not_found'));
        return;
      }

      // 5. 既にフレンドかチェック
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('meishies')
          .doc(userId)
          .get();

      if (friendDoc.exists) {
        _showError(ErrorHandler.getQRErrorMessage('already_friend'));
        return;
      }

      // 6. フレンド追加処理
      await _addFriend(currentUser.uid, userId, userDoc.data()!);

      _showSuccess('フレンドを追加しました');
      ErrorHandler.logInfo('QR Scan', 'Successfully added friend: $userId');
    } catch (e) {
      ErrorHandler.logError('QR scan', e);
      _showError('フレンド追加に失敗しました');
    }
  }

  /// QRコードからユーザーIDを抽出
  String? _extractUserIdFromQR(String qrData) {
    // QRコードのデータ形式に応じて調整
    // 例: "animeishi://user/{userId}" 形式の場合
    final uri = Uri.tryParse(qrData);
    if (uri?.scheme == 'animeishi' && uri?.pathSegments.length == 2) {
      if (uri!.pathSegments[0] == 'user') {
        return uri.pathSegments[1];
      }
    }

    // 直接ユーザーIDの場合
    if (RegExp(r'^[a-zA-Z0-9]{28}$').hasMatch(qrData)) {
      return qrData;
    }

    return null;
  }

  /// フレンド追加処理（双方向）
  Future<void> _addFriend(String currentUserId, String friendId, Map<String, dynamic> friendData) async {
    final batch = FirebaseFirestore.instance.batch();

    // 現在のユーザーのフレンドリストに追加
    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('meishies')
          .doc(friendId),
      {
        'userId': friendId,
        'userName': friendData['userName'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      },
    );

    // 相手のフレンドリストにも追加
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    batch.set(
      FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .collection('meishies')
          .doc(currentUserId),
      {
        'userId': currentUserId,
        'userName': currentUserDoc.data()?['userName'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  /// エラーメッセージ表示
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 成功メッセージ表示
  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF99),
        title: const Text('スキャンしよう'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // 戻るボタンを押したときにHomePageに遷移
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // HomePageに遷移
            );
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: MobileScanner(
        controller: controller,
        fit: BoxFit.contain,
        onDetect: (scandata) {
          final scannedUserId = scandata.barcodes.first.rawValue;
          print('スキャン結果: $scannedUserId');
          if (scannedUserId != null && scannedUserId.isNotEmpty) {
            setState(() {
              controller.stop(); // スキャン成功後にカメラを停止
              saveUserIdToFirestore(scannedUserId); // **Firestore に保存**
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) {
                    return ScanDataWidget(scandata: scandata);
                  },
                ),
              );
            });
          }
        },
      ),
    );
  }
}
