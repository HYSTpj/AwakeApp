import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'services/alarm_service.dart';
import 'services/vibration_service.dart';
import 'login/login_page.dart'; // ログインページのインポート

// Firebaseを利用するためのパッケージ
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';

// Supabaseを利用するためのパッケージ
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'database/database.dart';
import 'data/event_repository.dart';
import 'data/repositories/room_repository.dart';

void main() async {
  // Flutterを初期化
  WidgetsFlutterBinding.ensureInitialized();
  // Alarmを初期化
  await Alarm.init();

  try {
    // Firebaseを初期化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('初期化済み');
    } else {
      rethrow;
    }
  }

  // Supabaseを初期化
  await Supabase.initialize(
    url: 'https://nnxfbifnaebzfapgbfkr.supabase.co', // Project URL
    anonKey: 'sb_publishable_eldYHgMllFya3mprP7AMXw_SJrK6bkv', // Anon Key
  );

  //DriftDBとrepositoryのインスタンス化
  final database = AwakeDatabase(openConnection());
  final roomRepository = RoomRepository(database);

  runApp(
    MultiProvider(
      providers: [
        Provider<AwakeDatabase>.value(value: database),
        Provider<RoomRepository>.value(value: roomRepository),
      ],
      child: const MyApp(),
    ),
  );

  // 画面のUIスタート
  // runApp(const MyApp());
}

// アプリ全体の設定
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final EventRepository _eventRepository = EventRepository();
  final AlarmService _alarmService = RealAlarmService();
  final VibrationService _vibrationService = RealVibrationService();
  StreamSubscription<AlarmSet>? _ringingSubscription;
  Set<int> _lastRingingIds = {};
  bool _isDialogShowing = false;
  bool _isStoppingAlarm = false;

  Timer? _vibrationTimer;
  int _currentVibrationIntensity = 50;

  @override
  void initState() {
    super.initState();
    _ringingSubscription = _alarmService.ringing.listen((AlarmSet alarmSet) {
      final currentIds = alarmSet.alarms.map((a) => a.id).toSet();
      final newIds = currentIds.difference(_lastRingingIds);
      for (final id in newIds) {
        final alarm = alarmSet.alarms.firstWhere((a) => a.id == id);
        _showAlarmDialog(alarm);
        _startGradualVibration();
      }
      _lastRingingIds = currentIds;
    });
  }

  Future<void> _showAlarmDialog(AlarmSettings alarmSettings) async {
    if (_isDialogShowing) {
      return;
    }

    final context = _navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      return;
    }

    final payload = alarmSettings.payload;
    final alarmData = payload == null
        ? null
        : jsonDecode(payload) as Map<String, dynamic>;
    final eventId = alarmData?['eventId'] as String?;

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
                    if (_isStoppingAlarm) {
                      return;
                    }

                    _isStoppingAlarm = true;
                    Navigator.of(context).pop();

                    _stopCustomVibration();
                    await _alarmService.stop(alarmSettings.id);
                    if (eventId != null) {
                      try {
                        await _eventRepository.stopAlarmAndUpdateStatus(
                          eventId: eventId,
                          phase: alarmData?['phase'] as String? ?? '',
                        );
                      } catch (e) {
                        debugPrint('アラーム停止後のステータス更新に失敗: $e');
                      }
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
      _isDialogShowing = false;
      _isStoppingAlarm = false;
    }
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    _stopCustomVibration();
    super.dispose();
  }

  Future<void> _startGradualVibration() async {
    _stopCustomVibration();

    final hasAmplitude = await _vibrationService.hasAmplitudeControl() ?? false;
    _currentVibrationIntensity = 50;
    int secondsElapsed = 0;

    _vibrationTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (hasAmplitude) {
        await _vibrationService.vibrate(
          duration: 1000,
          amplitude: _currentVibrationIntensity,
        );

        secondsElapsed += 2;

        if (secondsElapsed >= 30) {
          secondsElapsed = 0;
          if (_currentVibrationIntensity < 255) {
            _currentVibrationIntensity = (_currentVibrationIntensity + 50).clamp(50, 255);
            debugPrint('バイブレーション強度が $_currentVibrationIntensity に上昇しました。');
          }
        }
      } else {
        await _vibrationService.vibrate(duration: 1000);
      }
    });
  }

  void _stopCustomVibration() {
    _vibrationTimer?.cancel();
    _vibrationTimer = null;
    _vibrationService.cancel();
  }

  // デザインシステム設定
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      title: 'Flutter Demo',
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
