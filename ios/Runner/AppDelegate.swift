import Flutter
import UIKit
import alarm

// 地図機能利用
import GoogleMaps
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  // Flutter側(MapsApiKeyService)にAPIキー設定状況を伝えるためのフラグ
  private var isMapsApiKeyConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Google Maps APIキー取得（ios/Flutter/Secrets.xcconfig → Info.plist 経由）
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "MapsAPIKey") as? String,
       !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
      isMapsApiKeyConfigured = true
    } else {
      print("⚠️ Google Maps API key is not set. See ios/Flutter/Secrets.xcconfig.example")
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let mapsApiKeyChannel = FlutterMethodChannel(
      name: "com.example.flutterApplication1/maps_api_key",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    mapsApiKeyChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "isConfigured" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(self?.isMapsApiKeyConfigured ?? false)
    }
  }
}
