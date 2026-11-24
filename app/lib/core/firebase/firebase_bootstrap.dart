import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'firebase_environment.dart';
import 'firebase_options_dev.dart' as staging_opts;
import 'firebase_options_prod.dart' as prod_opts;

/// Initialise Firebase. Debug → `sipho-staging` ; release → `sipho-f5a01`.
Future<void> bootstrapFirebase() async {
  if (Firebase.apps.isNotEmpty) return;

  final flavor = kReleaseMode ? 'prod' : 'dev';
  final options = kReleaseMode
      ? prod_opts.DefaultFirebaseOptions.currentPlatform
      : staging_opts.DefaultFirebaseOptions.currentPlatform;

  assertFirebaseConfigured(options, flavor: flavor);
  await Firebase.initializeApp(options: options);

  // App Check required for Firebase AI Logic + hardened callables.
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider:
          kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
      appleProvider:
          kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
    );
  } catch (e) {
    debugPrint('[Firebase] App Check activate skipped: $e');
  }

  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults(const {
      'ai_model': 'gemini-3.5-flash-lite',
      'scan_quota_per_day': 5,
      'receipt_model': 'gemini-3.5-flash-lite',
    });
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 1),
      ),
    );
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    debugPrint('[Firebase] Remote Config skipped: $e');
  }
}
