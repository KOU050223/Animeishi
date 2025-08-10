#!/usr/bin/env dart

import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    showHelp();
    return;
  }

  final command = args[0];
  final extraArgs = args.length > 1 ? args.sublist(1) : <String>[];

  switch (command) {
    case 'ci':
      runCI(extraArgs);
      break;
    case 'format':
      runFormat(extraArgs);
      break;
    case 'lint':
      runLint(extraArgs);
      break;
    case 'test':
      runTest(extraArgs);
      break;
    case 'fix':
      runFix(extraArgs);
      break;
    case 'clean':
      runClean(extraArgs);
      break;
    default:
      print('❌ 不明なコマンド: $command');
      showHelp();
      exit(1);
  }
}

void showHelp() {
  print('''
Flutter開発用スクリプトランナー

使用方法: dart run scripts/run.dart <command> [options]

利用可能なコマンド:
  ci      - CI用の全チェック（format-check + lint + test）
  format  - コードフォーマット
  lint    - 静的解析
  test    - テスト実行
  fix     - 自動修正（format + analyze --fix）
  clean   - キャッシュクリア

例:
  dart run scripts/run.dart ci
  dart run scripts/run.dart test --coverage
  dart run scripts/run.dart format
''');
}

Future<void> runCI(List<String> extraArgs) async {
  print('🚀 CI チェックを開始...');
  
  await runCommand('flutter', ['pub', 'get']);
  
  print('🎨 フォーマットチェック...');
  await runCommand('dart', ['format', '--set-exit-if-changed', '.']);
  
  print('🔍 静的解析...');
  await runCommand('flutter', ['analyze', '--fatal-infos']);
  
  print('🧪 テスト実行...');
  await runCommand('flutter', ['test', ...extraArgs]);
  
  print('✅ すべてのチェックが完了しました!');
}

Future<void> runFormat(List<String> extraArgs) async {
  print('🎨 コードフォーマット中...');
  await runCommand('dart', ['format', '.', ...extraArgs]);
  print('✅ フォーマット完了!');
}

Future<void> runLint(List<String> extraArgs) async {
  print('🔍 静的解析実行中...');
  await runCommand('flutter', ['pub', 'get']);
  await runCommand('flutter', ['analyze', ...extraArgs]);
  print('✅ 静的解析完了!');
}

Future<void> runTest(List<String> extraArgs) async {
  print('🧪 テスト実行中...');
  await runCommand('flutter', ['pub', 'get']);
  await runCommand('flutter', ['test', ...extraArgs]);
  print('✅ テスト完了!');
}

Future<void> runFix(List<String> extraArgs) async {
  print('🔧 自動修正実行中...');
  await runCommand('flutter', ['pub', 'get']);
  await runCommand('dart', ['format', '.']);
  await runCommand('flutter', ['analyze', '--fix']);
  print('✅ 自動修正完了!');
}

Future<void> runClean(List<String> extraArgs) async {
  print('🧹 クリーンアップ中...');
  await runCommand('flutter', ['clean']);
  await runCommand('flutter', ['pub', 'get']);
  print('✅ クリーンアップ完了!');
}

Future<void> runCommand(String command, List<String> arguments) async {
  final result = await Process.run(command, arguments);
  
  if (result.stdout.isNotEmpty) {
    print(result.stdout);
  }
  
  if (result.stderr.isNotEmpty) {
    stderr.write(result.stderr);
  }
  
  if (result.exitCode != 0) {
    exit(result.exitCode);
  }
}