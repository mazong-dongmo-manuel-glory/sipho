import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/app/app.dart';
import 'package:sipho/core/ai/sipho_ai_client.dart';
import 'package:sipho/core/animations/sipho_lotties.dart';
import 'package:sipho/core/firebase/app_check_setup.dart';
import 'package:sipho/core/firebase/firebase_environment.dart';

Future<void> bootstrap(FirebaseOptions options,
    {required String flavor}) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Refuse to run a flavor that is unconfigured or wired to another environment's project.
      try {
        assertFirebaseConfigured(options, flavor: flavor);
      } on StateError catch (error) {
        runApp(_ConfigErrorApp(message: error.message));
        return;
      }

      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(options: options);
        }
      } catch (e) {
        debugPrint('Firebase.initializeApp warning: $e');
      }

      // App Check right after Firebase.initializeApp, before any other Firebase service.
      try {
        await activateAppCheck();
      } catch (e) {
        debugPrint('FirebaseAppCheck warning: $e');
      }

      try {
        await FirebaseRemoteConfig.instance.setDefaults(const <String, dynamic>{
          'ai_model': defaultAiModel,
          // Mirrors SCAN_QUOTA_PER_DAY on parseReceipt (server remains the source of truth).
          'scan_quota_per_day': 5,
        });
        unawaited(
          FirebaseRemoteConfig.instance
              .fetchAndActivate()
              .catchError((Object _) => false),
        );
      } catch (e) {
        debugPrint('FirebaseRemoteConfig warning: $e');
      }

      try {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
      } catch (e) {
        debugPrint('FirebaseCrashlytics warning: $e');
      }

      runApp(ProviderScope(child: SiphoApp(flavor: flavor)));
      unawaited(preloadSiphoLotties());
    },
    (error, stack) {
      debugPrint('Unhandled bootstrap error: $error\n$stack');
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {}
    },
  );
}

class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(message)),
          ),
        ),
      ),
    );
  }
}
