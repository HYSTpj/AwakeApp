import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'services/alarm_service.dart';
import 'services/gradual_vibration_controller.dart';
import 'services/vibration_service.dart';
import 'presentation/views/login/login_page.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

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
import 'data/repositories/group_repository.dart';

// ViewModel
import 'presentation/viewmodels/auth_view_model.dart';
import 'presentation/viewmodels/admin_event_view_model.dart';
import 'presentation/viewmodels/group_view_model.dart';

void main() async {
  // Flutterを初期化
  WidgetsFlutterBinding.ensureInitialized();
  // Alarmを初期化
  await Alarm.init();

  // Supabaseを初期化
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    publishableKey: EnvConfig.supabaseAnonKey,
  );

  final client = Supabase.instance.client;

  // Drift DB
  final database = AwakeDatabase(openConnection());
  final roomRepository = RoomRepository(database);

  // Supabase Repositories
  final authRepository = SupabaseAuthRepository(client);
  final adminEventRepository = SupabaseAdminEventRepository(client);
  final memberEventRepository = SupabaseMemberEventRepository(client);
  final groupRepository = SupabaseGroupRepository(client);

  runApp(
    MultiProvider(
      providers: [
        Provider<AwakeDatabase>.value(value: database),
        Provider<RoomRepository>.value(value: roomRepository),

        // 各種リポジトリ
        Provider<AuthRepository>.value(value: authRepository),
        Provider<AdminEventRepository>.value(value: adminEventRepository),
        Provider<MemberEventRepository>.value(value: memberEventRepository),
        Provider<GroupRepository>.value(value: groupRepository),

        // 共通 ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository),
        ),
        ChangeNotifierProvider<AdminEventViewModel>(
          create: (_) => AdminEventViewModel(adminEventRepository),
        ),
        ChangeNotifierProvider<GroupViewModel>(
          create: (_) => GroupViewModel(groupRepository),
        ),
      ],
      child: MyApp(memberEventRepository: memberEventRepository),
    ),
  );
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
  int? _showingDialogAlarmId;
  final List<AlarmSettings> _pendingDialogAlarms = [];
  final Set<int> _stoppedAlarmIds = {};
  final Map<int, GradualVibrationController> _vibrationControllers = {};
  final VibrationService _vibrationService = RealVibrationService.instance;

  @override
  void initState() {
    super.initState();
    _ringingSubscription = _alarmService.ringing.listen((AlarmSet alarmSet) {
      final currentIds = alarmSet.alarms.map((a) => a.id).toSet();
      final newIds = currentIds.difference(_lastRingingIds);
      for (final id in newIds) {
        final alarm = alarmSet.alarms.firstWhere((a) => a.id == id);
        unawaited(_showAlarmDialog(alarm));
        unawaited(_startGradualVibration(alarm.id));
      }

      final removedIds = _lastRingingIds.difference(currentIds);
      for (final id in removedIds) {
        _stopCustomVibration(id);
        _pendingDialogAlarms.removeWhere((a) => a.id == id);

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

                    _stoppedAlarmIds.add(alarmSettings.id);
                    Navigator.of(context).pop();

                    _stopCustomVibration(alarmSettings.id);

                    try {
                      await _alarmService.stop(alarmSettings.id);

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
                          if (result != null && result['success'] != true) {
                            debugPrint('アラーム停止後のステータス更新に失敗: $result');
                          }
                        } catch (e) {
                          debugPrint('アラーム停止後のステータス更新に失敗: $e');
                        }
                      }
                    } finally {
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
    final existing = _vibrationControllers.remove(alarmId);
    if (existing != null) {
      unawaited(
        existing.stop(cancelVibration: _vibrationControllers.isEmpty),
      );
    }

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
      unawaited(
        controller.stop(cancelVibration: _vibrationControllers.isEmpty),
      );
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 【追加】Flutterの標準コンポーネント（カレンダーやダイアログのボタン等）を日本語に対応させる設定
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ja', 'JP'), // デフォルトの言語を日本語に設定
      // 最初に表示する画面
      home: LoginPage(),
    );
  }
}