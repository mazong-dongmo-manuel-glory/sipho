import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    #if DEBUG
      // Debug builds only: imposes the dev App Check debug token chosen in Dart, so it survives
      // reinstalls and is the same on every simulator (App Check reads this key when it activates).
      let channel = FlutterMethodChannel(
        name: "com.cargonomade.sipho/app_check_debug",
        binaryMessenger: engineBridge.applicationRegistrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "seedDebugToken", let token = call.arguments as? String, !token.isEmpty {
          UserDefaults.standard.set(token, forKey: "GACAppCheckDebugToken")
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    #endif
  }
}
