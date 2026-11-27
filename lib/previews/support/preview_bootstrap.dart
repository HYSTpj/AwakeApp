// Widget Preview 専用のブートストラップ。
// Supabase.instance への直接アクセス（CommonHeader 等）がクラッシュしないよう、
// プレビュー表示前にダミー値で一度だけ初期化する。
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> ensurePreviewSupabaseInitialized() async {
  try {
    // 既に初期化済みなら例外を投げずに素通りする。
    Supabase.instance.client;
  } catch (_) {
    await Supabase.initialize(
      url: 'https://preview.supabase.co',
      publishableKey: 'preview-anon-key',
    );
  }
}

/// Widget Preview のエントリポイントで使う共通ラッパー。
/// Supabase の非同期初期化が終わるまでスピナーを表示し、完了後に
/// [child] を MaterialApp でラップして表示する。
class PreviewApp extends StatefulWidget {
  final Widget child;

  const PreviewApp({super.key, required this.child});

  @override
  State<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<PreviewApp> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    ensurePreviewSupabaseInitialized().then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: widget.child,
    );
  }
}
