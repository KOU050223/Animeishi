import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanDataWidget extends StatelessWidget {
  final BarcodeCapture? scandata; // スキャナーのページから渡されたデータ
  const ScanDataWidget({
    super.key,
    this.scandata,
  });

  @override
  Widget build(BuildContext context) {
    // コードから読み取った文字列
    String codeValue = scandata?.barcodes.first.rawValue ?? 'null';
    // コードのタイプを示すオブジェクト
    BarcodeType? codeType = scandata?.barcodes.first.type;
    // コードのタイプを文字列にする
    String cardTitle = "[${'$codeType'.split('.').last}]";
    // 読み取った内容を表示するウィジェット
    dynamic cardSubtitle = Text(codeValue,
        style: const TextStyle(fontSize: 23, color: Color(0xFF553311)));

    // タイプがURLである場合
    if (codeType == BarcodeType.url) {
      cardTitle = 'どこかのURL';
      cardSubtitle = InkWell(
        child: Text(
          codeValue,
          style: const TextStyle(
            fontSize: 23,
            color: Color(0xFF1133DD), // 藍色の文字
            decoration: TextDecoration.underline, // 下線
            decorationColor: Color(0xFF1133DD), // 下線の色
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF99),
        title: const Text('スキャンの結果'),
      ),
      body: Card(
        color: const Color(0xFFBBFFDD),
        elevation: 5,
        margin: const EdgeInsets.all(9),
        child: ListTile(
          title: Text(
            cardTitle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          subtitle: cardSubtitle,
        ),
      ),
    );
  }
}
