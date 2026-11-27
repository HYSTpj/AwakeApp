import 'package:flutter/services.dart';

abstract class MapsApiKeyService {
  Future<bool> isConfigured();
}

class RealMapsApiKeyService implements MapsApiKeyService {
  const RealMapsApiKeyService();

  static const MethodChannel _channel = MethodChannel(
    'com.example.flutterApplication1/maps_api_key',
  );

  @override
  Future<bool> isConfigured() async {
    try {
      final result = await _channel.invokeMethod<bool>('isConfigured');
      return result ?? false;
    } on MissingPluginException {
      // ネイティブ側が未実装のプラットフォームでは地図を隠さない
      return true;
    }
  }
}
