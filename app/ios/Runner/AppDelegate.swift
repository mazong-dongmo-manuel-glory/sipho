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
      let channel = FlutterMethodChannel(
        name: "com.cargonomade.sipho/app_check_debug",
        binaryMessenger: engineBridge.applicationRegistrar.messenger()
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "getDebugToken" {
          let defaults = UserDefaults.standard
          let token = defaults.string(forKey: "GACAppCheckDebugToken")
            ?? defaults.string(forKey: "FIRAAppCheckDebugToken")
          result(token)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    #endif
  }
}
