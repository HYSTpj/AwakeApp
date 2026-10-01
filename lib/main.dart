import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'services/alarm_service.dart';
import 'services/gradual_vibration_controller.dart';
import 'services/vibration_service.dart';
import 'presentation/views/login/login_page.dart'; // ログインページのインポート

// Supabaseを利用するためのパッケージ
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/database/database.dart';
import 'config/env_config.dart';

// リポジトリ
import 'data/repositories/room_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/admin_event_repository.dart';
import 'data/repositories/member_event_repository.dart';

// ViewModel
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/admin_event_view_model.dart';

void main() async {
  // Flutterを初期化
  WidgetsFlutterBinding.ensureInitialized();
  // Alarmを初期化
  await Alarm.init();

  // Supabaseを初期化
  // 直書き文字列から EnvConfig 経由に変更
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  // Drift DB
  final database = AwakeDatabase(openConnection());
  final roomRepository = RoomRepository(database);

  // Supabase Repositories
  final authRepository = SupabaseAuthRepository(client);
  final adminEventRepository = SupabaseAdminEventRepository(client);
  final memberEventRepository = SupabaseMemberEventRepository(client);

  runApp(
    MultiProvider(
      providers: [
        Provider<AwakeDatabase>.value(value: database),
        Provider<RoomRepository>.value(value: roomRepository),

        // 各種リポジトリ
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AdminEventRepository>.value(value: adminEventRepository),
        Provider<MemberEventRepository>.value(value: memberEventRepository),

        // 共通 ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository),
        ),
        ChangeNotifierProvider<AdminEventViewModel>(
          create: (_) => AdminEventViewModel(adminEventRepository),
        ),
      ],
      child: MyApp(memberEventRepository: memberEventRepository),
    ),
  );

  // 画面のUIスタート
  // runApp(const MyApp());
}

// アプリ全体の設定
class MyApp extends StatefulWidget {
  final MemberEventRepository memberEventRepository;

  const MyApp({super.key, required this.memberEventRepository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final AlarmService _alarmService = RealAlarmService();
  StreamSubscription<AlarmSet>? _ringingSubscription;
  Set<int> _lastRingingIds = {};
  // 現在画面に表示中のダイアログがどのアラームのものかを記録しておく。
  // nullなら何も表示していない。通知経由でそのアラームが停止された場合に、
  // このダイアログを閉じるためにも使う。
  int? _showingDialogAlarmId;
  // 複数のアラームが同時に鳴った場合、ダイアログは重ねて表示せず、
  // 表示中のダイアログが閉じてから次を表示するための待ち行列。
  final List<AlarmSettings> _pendingDialogAlarms = [];
  // アラームIDごとに「停止済み」を管理する（全体で1つのフラグだと他のアラームに影響してしまうため）
  final Set<int> _stoppedAlarmIds = {};
  // アラームIDごとにバイブレーションコントローラーを持つ（1つを使い回すと、
  // 複数のアラームが同時に鳴った場合に後から鳴ったアラームが先のアラームの
  // バイブレーションを乗っ取ってしまう）
  final Map<int, GradualVibrationController> _vibrationControllers = {};
  // 振幅制御対応の問い合わせ結果をアラームをまたいでキャッシュできるよう、
  // VibrationServiceはアプリ全体で1つのインスタンスを使い回す
  // （GradualVibrationControllerはアラームごとに作り直すが、
  // こちらは共有する）。RealVibrationServiceはコンストラクタがprivateな
  // ため、.instance以外の取得手段がなく、常に同じインスタンスになる。
  final VibrationService _vibrationService = RealVibrationService.instance;

  @override
  void initState() {
    super.initState();
    _ringingSubscription = _alarmService.ringing.listen((AlarmSet alarmSet) {
      final currentIds = alarmSet.alarms.map((a) => a.id).toSet();
      final newIds = currentIds.difference(_lastRingingIds);
      for (final id in newIds) {
        final alarm = alarmSet.alarms.firstWhere((a) => a.id == id);
        // どちらもFuture<void>を返すが、リスナー内では結果を待つ必要がない。
        // 明示的にunawaited()で囲むことで、内部で例外が発生した場合に
        // 静かに握りつぶされるのではなく、Zoneのエラーハンドラーに届くようにする。
        unawaited(_showAlarmDialog(alarm));
        unawaited(_startGradualVibration(alarm.id));
      }

      // 通知の停止アクションなど、アプリ内ダイアログを経由しない経路で
      // アラームが止まった場合もここで検知し、カスタムバイブレーションを止める。
      final removedIds = _lastRingingIds.difference(currentIds);
      for (final id in removedIds) {
        _stopCustomVibration(id);
        _pendingDialogAlarms.removeWhere((a) => a.id == id);

        // このアラームのダイアログが今まさに表示中であれば、それも閉じる。
        // ダイアログのストップボタン自身がpopした直後は、既に
        // _showingDialogAlarmIdがnullに戻っているため二重にpopされることはない。
        if (_showingDialogAlarmId == id) {
          final navigatorState = _navigatorKey.currentState;
          if (navigatorState != null && navigatorState.canPop()) {
            navigatorState.pop();
          }
        }
      }

      _lastRingingIds = currentIds;
    });
  }

  Future<void> _showAlarmDialog(AlarmSettings alarmSettings) async {
    if (_showingDialogAlarmId != null) {
      // 表示中のダイアログがあれば、それが閉じてから表示するために
      // 待ち行列に積んでおく（重ねて表示すると操作不能なポップアップが
      // 積み重なってしまうため）。
      _pendingDialogAlarms.add(alarmSettings);
      return;
    }

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    _showingDialogAlarmId = alarmSettings.id;

    final payload = alarmSettings.payload;
    final alarmData = payload == null
        ? null
        : jsonDecode(payload) as Map<String, dynamic>;
    final eventId = alarmData?['eventId'] as String?;
    final phase = alarmData?['phase'] as String? ?? '';

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(alarmSettings.notificationSettings.title),
            content: Text(alarmSettings.notificationSettings.body),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  onPressed: () async {
                    if (_stoppedAlarmIds.contains(alarmSettings.id)) {
                      return;
                    }

                    // このアラームIDだけを「停止済み」にする（他のアラームには影響しない）
                    _stoppedAlarmIds.add(alarmSettings.id);
                    Navigator.of(context).pop();

                    _stopCustomVibration(alarmSettings.id);

                    try {
                      await _alarmService.stop(alarmSettings.id);

                      // Supabase RPC経由で起床/出発の打刻処理を実行
                      if (eventId != null) {
                        try {
                          Map<String, dynamic>? result;
                          if (phase == 'wakeup') {
                            result = await widget.memberEventRepository
                                .reportWakeUp(eventId);
                          } else if (phase == 'departure') {
                            result = await widget.memberEventRepository
                                .reportDeparture(eventId);
                          }
                          // RPCは例外を投げずに失敗を返すことがあるため、
                          // successフィールドも確認する（チェックイン画面の
                          // MemberCheckInViewModelと同じ確認方法に合わせている）。
                          if (result != null && result['success'] != true) {
                            debugPrint('アラーム停止後のステータス更新に失敗: $result');
                          }
                        } catch (e) {
                          debugPrint('アラーム停止後のステータス更新に失敗: $e');
                        }
                      }
                    } finally {
                      // 停止処理が完全に終わってから印を外す（ダイアログが閉じた瞬間ではない）
                      _stoppedAlarmIds.remove(alarmSettings.id);
                    }
                  },
                  child: const Text(
                    'ストップ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      _showingDialogAlarmId = null;
      if (_pendingDialogAlarms.isNotEmpty) {
        final next = _pendingDialogAlarms.removeAt(0);
        _showAlarmDialog(next);
      }
    }
  }

  Future<void> _startGradualVibration(int alarmId) {
    final controller = GradualVibrationController(
      vibrationService: _vibrationService,
    );
    _vibrationControllers[alarmId] = controller;
    return controller.start(
      isCancelled: () => _stoppedAlarmIds.contains(alarmId),
    );
  }

  void _stopCustomVibration(int alarmId) {
    final controller = _vibrationControllers.remove(alarmId);
    if (controller != null) {
      unawaited(controller.stop());
    }
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    for (final id in _vibrationControllers.keys.toList()) {
      _stopCustomVibration(id);
    }
    super.dispose();
  }

  // デザインシステム設定
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'Awake App',
      theme: ThemeData(
        // デザインタイプの有効設定
        useMaterial3: true,
        // アプリ全体の基本色設定
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 最初に表示する画面
      home: LoginPage(),
    );
  }
}
