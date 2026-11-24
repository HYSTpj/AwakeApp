import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/maps_api_key_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.flutterApplication1/maps_api_key');
  const service = RealMapsApiKeyService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('ネイティブ側がtrueを返す場合、isConfiguredはtrueになること', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => true);

    expect(await service.isConfigured(), isTrue);
  });

  test('ネイティブ側がfalseを返す場合、isConfiguredはfalseになること', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => false);

    expect(await service.isConfigured(), isFalse);
  });

  test('チャネルが未実装の場合（MissingPluginException）、trueにフォールバックすること', () async {
    // ハンドラを設定しないまま呼び出すと MissingPluginException が発生する
    expect(await service.isConfigured(), isTrue);
  });
}
