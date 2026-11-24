// Widget Preview 専用のブートストラップ。
// Supabase.instance への直接アクセス（CommonLayout 等）がクラッシュしないよう、
// プレビュー表示前にダミー値で一度だけ初期化する。
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/viewmodels/admin_event_view_model.dart';
import '../../presentation/viewmodels/auth_view_model.dart';
import '../../presentation/viewmodels/group_view_model.dart';
import 'mock_repositories.dart';

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

/// 全プレビューで共通して使う ViewModel 群。
/// 未ログイン状態のため Supabase 直叩きの画面はネットワークに出ないが、
/// Provider 経由でモックを渡すことで ChangeNotifierProvider 依存の画面も動かせる。
List<SingleChildWidget> previewProviders() => [
      ChangeNotifierProvider<AuthViewModel>(
        create: (_) => AuthViewModel(MockAuthRepository()),
      ),
      ChangeNotifierProvider<AdminEventViewModel>(
        create: (_) => AdminEventViewModel(MockAdminEventRepository()),
      ),
      ChangeNotifierProvider<GroupViewModel>(
        create: (_) => GroupViewModel(MockGroupRepository()),
      ),
    ];

/// Widget Preview のエントリポイントで使う共通ラッパー。
/// Supabase の非同期初期化が終わるまでスピナーを表示し、完了後に
/// [child] を MaterialApp + Provider でラップして表示する。
class PreviewApp extends StatefulWidget {
  final Widget child;
  final List<SingleChildWidget> providers;

  const PreviewApp({
    super.key,
    required this.child,
    this.providers = const [],
  });

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

    final body = widget.providers.isEmpty
        ? widget.child
        : MultiProvider(providers: widget.providers, child: widget.child);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: body,
    );
  }
}

/// 未ログイン状態だと初期化直後に `Navigator.pop()` を呼ぶページ
/// （例: MemberCheckInPage）をプレビューする際に使う。
/// ダミーの1ページ目を下に敷いておくことで、pop() してもスタックが
/// 空にならずクラッシュ/ブラックスクリーンにならないようにする。
class PreviewWithBackStack extends StatefulWidget {
  final Widget child;

  const PreviewWithBackStack({super.key, required this.child});

  @override
  State<PreviewWithBackStack> createState() => _PreviewWithBackStackState();
}

class _PreviewWithBackStackState extends State<PreviewWithBackStack> {
  late List<Page<void>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const MaterialPage<void>(child: Scaffold(body: SizedBox.shrink())),
      MaterialPage<void>(child: widget.child),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: List.of(_pages),
      onDidRemovePage: (page) {
        setState(() => _pages.remove(page));
      },
    );
  }
}
