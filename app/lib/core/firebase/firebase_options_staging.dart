// Firebase options for the STAGING flavor (`lib/main_staging.dart`).
//
// PLACEHOLDER: this environment has no Firebase project wired yet. Until you run
//   flutterfire configure --project=sipho-staging --out=lib/core/firebase/firebase_options_staging.dart
// the app refuses to start in this flavor (see `assertFirebaseConfigured`) instead of silently
// falling back to the dev project.
//
// Also add the matching android/app/src/staging/google-services.json (downloaded for package
// com.cargonomade.sipho.staging): on Android the native config, not this file, initialises the default Firebase app.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:sipho/core/firebase/firebase_environment.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for Sipho.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: kUnconfiguredFirebaseValue,
    appId: kUnconfiguredFirebaseValue,
    messagingSenderId: kUnconfiguredFirebaseValue,
    projectId: 'sipho-staging',
    storageBucket: 'sipho-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: kUnconfiguredFirebaseValue,
    appId: kUnconfiguredFirebaseValue,
    messagingSenderId: kUnconfiguredFirebaseValue,
    projectId: 'sipho-staging',
    storageBucket: 'sipho-staging.firebasestorage.app',
    iosBundleId: 'com.cargonomade.sipho.staging',
  );
}
