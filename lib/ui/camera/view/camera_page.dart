import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState () => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late List<CameraDescription> _cameras;
  late CameraController _controller;
  late Future<void>  _initializeControllerFuture;

   @override
   void initState() {
    super.initState();
    _initializeCamera();
}

 Future<void> _initializeCamera() async {
    // カメラのリストを取得
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[0], // 最初のカメラを選択 (通常は背面カメラ)
      ResolutionPreset.high, // 解像度を指定
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {}); // UIを更新
  }

  @override
  void dispose() {
    _controller.dispose(); //リソースを開放
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      // カメラが初期化されるのを待つ
      await _initializeControllerFuture;
      // 写真を撮影
      final image = await _controller.takePicture();
      // 撮影した画像のパス
      final imagePath = image.path;

      // 撮影後の処理 (例: 表示する)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: imagePath),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_controller == null || !_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('カメラ')
      ),
     body: FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller); //カメラプレビュー
        } else {
          return const Center(child: CircularProgressIndicator()); //ローディング中
        }
      },
     ),
     floatingActionButton: FloatingActionButton(
      onPressed: _takePicture,
      child: const Icon(Icons.qr_code),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath}) :
  super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('撮影した画像'),
      ),
    body: Center(
     child: Image.file(File(imagePath)),
     )
    );
  }
}