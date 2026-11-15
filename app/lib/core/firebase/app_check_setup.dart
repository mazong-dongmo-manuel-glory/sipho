import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Debug token of the DEV Firebase project (sipho-f5a01), registered once in
/// Firebase Console > App Check > Apps > (Android and iOS) > Manage debug tokens.
///
/// It is a credential: the repository is public, so it must NEVER be written in the source. It is
/// passed at launch with `--dart-define=APP_CHECK_DEBUG_TOKEN=<uuid>` (kept in the git-ignored
/// `.vscode/launch.json`). Without it, the debug provider falls back to a random per-install
/// token (printed in the logs, to register in the console).
///
/// It is only ever used by debug builds: the same token is imposed on every emulator, simulator
/// and reinstall, so nothing has to be re-registered. Release builds never read it (real
/// providers), and the native side ignores it unless the app is debuggable. If it leaks, delete it
/// in the console and generate a new one (`uuidgen`).
const kDevAppCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

/// `flutter run --dart-define=APP_CHECK_REAL=true` exercises Play Integrity / App Attest in a
/// debug build (physical device only).
const bool kAppCheckRealProviders = bool.fromEnvironment('APP_CHECK_REAL');

const _channel = MethodChannel('com.cargonomade.sipho/app_check_debug');

/// Whether this run attests with the debug provider (debug builds) or the real ones (release).
bool get usesAppCheckDebugProvider => kDebugMode && !kAppCheckRealProviders;

/// Activates App Check. Call right after `Firebase.initializeApp`, before any other Firebase
/// service is used.
Future<void> activateAppCheck() async {
  final debug = usesAppCheckDebugProvider;
  if (debug && kDevAppCheckDebugToken.isNotEmpty) {
    try {
      await _channel.invokeMethod<void>(
          'seedDebugToken', kDevAppCheckDebugToken);
    } catch (error) {
      debugPrint('[AppCheck] could not seed the debug token: $error');
    }
  }
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        debug ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: debug
        ? AppleProvider.debug
        : AppleProvider.appAttestWithDeviceCheckFallback,
  );
}
