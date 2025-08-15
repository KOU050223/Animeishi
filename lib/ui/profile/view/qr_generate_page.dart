import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/qr_image_service.dart';

/// QRコード生成・表示ページ
class QRGeneratePage extends StatefulWidget {
  const QRGeneratePage({super.key});

  @override
  State<QRGeneratePage> createState() => _QRGeneratePageState();
}

class _QRGeneratePageState extends State<QRGeneratePage> {
  Uint8List? _qrImageData;
  bool _isGenerating = false;
  String _customText = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateUserQR();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// ユーザーID用のQRコードを生成
  Future<void> _generateUserQR() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // ユーザーIDのみでQR生成
        final imageData = await QRImageService.generateQRImage(user.uid);
        setState(() {
          _qrImageData = imageData;
        });
      }
    } catch (e) {
      _showError('QRコード生成に失敗しました: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// カスタムテキストでQRコードを生成
  Future<void> _generateCustomQR(String text) async {
    if (text.trim().isEmpty) {
      _showError('テキストを入力してください');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final qrData = await QRImageService.generateQRImage(text);
      setState(() {
        _qrImageData = qrData;
        _customText = text;
      });
    } catch (e) {
      _showError('QRコード生成に失敗しました: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  /// ブランドカラーQRを生成
  Future<void> _generateBrandedQR() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // ユーザーIDのみでブランドカラーQR生成
      final imageData = await QRImageService.generateQRImage(
        user.uid,
        foregroundColor: const Color(0xFF667EEA),
        backgroundColor: Colors.white,
      );
      setState(() {
        _qrImageData = imageData;
      });
    } catch (e) {
      _showError('QRコード生成に失敗しました: $e');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QRコード生成'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8D5FF),
              Color(0xFFB8E6FF),
              Color(0xFFFFD6E8),
              Color(0xFFE8FFD6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // QRコード表示エリア
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'QRコード',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_isGenerating)
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text('生成中...'),
                            ],
                          ),
                        )
                      else if (_qrImageData != null)
                        Container(
                          width: 256,
                          height: 256,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _qrImageData!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 256,
                          height: 256,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text('QRコードが表示されます'),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (user != null)
                        Text(
                          'ユーザー: ${user.email}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      if (_customText.isNotEmpty)
                        Text(
                          'データ: $_customText',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // コントロールエリア
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'QRコード生成',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ユーザーQR生成ボタン
                      ElevatedButton(
                        onPressed: _isGenerating ? null : _generateUserQR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('自分のQRコードを生成'),
                      ),

                      const SizedBox(height: 12),

                      // ブランドQR生成ボタン
                      ElevatedButton(
                        onPressed: _isGenerating ? null : _generateBrandedQR,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF764BA2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('ブランドカラーQRを生成'),
                      ),

                      const SizedBox(height: 16),

                      // カスタムテキスト入力
                      const Text(
                        'カスタムテキスト',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: '任意のテキストを入力',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isGenerating
                            ? null
                            : () => _generateCustomQR(_textController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('カスタムQRを生成'),
                      ),
                    ],
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
