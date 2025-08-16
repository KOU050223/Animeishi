import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:animeishi/ui/components/web_firebase_image.dart';
import 'package:animeishi/ui/home/constants/meishi_constants.dart';

/// 名刺拡大表示ページ
class MeishiDetailPage extends StatefulWidget {
  final String imageURL;
  final String? storagePath;

  const MeishiDetailPage({
    super.key,
    required this.imageURL,
    this.storagePath,
  });

  @override
  State<MeishiDetailPage> createState() => _MeishiDetailPageState();
}

class _MeishiDetailPageState extends State<MeishiDetailPage> {
  @override
  void initState() {
    super.initState();
    // 縦向き固定を維持
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  /// Firebase Storage URLからパスを抽出
  String? _extractStoragePathFromURL(String imageURL) {
    try {
      final uri = Uri.parse(imageURL);
      final pathSegments = uri.pathSegments;

      // "/v0/b/bucket-name/o/" の後のパスを取得
      String storagePath = '';
      bool foundO = false;
      for (int i = 0; i < pathSegments.length; i++) {
        if (pathSegments[i] == 'o' && i + 1 < pathSegments.length) {
          foundO = true;
          continue;
        }
        if (foundO) {
          storagePath = pathSegments.sublist(i).join('/');
          break;
        }
      }

      if (storagePath.isNotEmpty) {
        final decodedPath = Uri.decodeComponent(storagePath);
        return decodedPath;
      }
    } catch (e) {
      print('Storage パス抽出エラー: $e');
    }
    return null;
  }

  /// 拡大表示用のエラーウィジェット
  Widget _buildDetailErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade400,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '名刺画像を読み込めませんでした',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '画像の表示に問題が発生しました',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 拡大表示用のプレースホルダーウィジェット
  Widget _buildDetailPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF667EEA),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '名刺画像読み込み中...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'しばらくお待ちください',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storagePath = widget.storagePath ?? _extractStoragePathFromURL(widget.imageURL);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // メイン画像表示エリア
          GestureDetector(
            onTap: () => Navigator.of(context).pop(), // タップで閉じる
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: storagePath != null
                    ? InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: EdgeInsets.zero, // 枠を完全に除去
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Transform.rotate(
                          angle: -math.pi / 2, // -90度（左回転）
                          child: SizedBox(
                            // 画面の最大領域を使用しつつ、中央配置で最適化
                            width: MediaQuery.of(context).size.height,
                            height: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                              aspectRatio: MeishiConstants.aspectRatio, // 想定される名刺画像の比率（1075:650）
                              child: WebFirebaseImage(
                                imagePath: storagePath,
                                fit: BoxFit.contain, // アスペクト比を保持して全体を表示
                                placeholder: Transform.rotate(
                                  angle: math.pi / 2, // プレースホルダーは元に戻す（+90度）
                                  child: _buildDetailPlaceholder(),
                                ),
                                errorWidget: Transform.rotate(
                                  angle: math.pi / 2, // エラーウィジェットも元に戻す（+90度）
                                  child: _buildDetailErrorWidget(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : _buildDetailErrorWidget(), // ストレージパスがない場合はエラーのみ表示（回転なし）
              ),
            ),
          ),
          // 閉じるボタン（画面右上に配置）
          Positioned(
            top: MediaQuery.of(context).padding.top + 16, // StatusBar下に配置
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5), // 半透明の背景
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}