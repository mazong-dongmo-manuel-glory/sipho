// PLACEHOLDER — replace with actual generated options from FlutterFire CLI
// Run: flutterfire configure --project=sipho-dev
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // REPLACE with actual values after flutterfire configure
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'sipho-dev',
    storageBucket: 'sipho-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_M1cL3IQr1kvW5lUFnSF0DbBPQWArlhY',
    appId: '1:303740226831:android:b8b1622ba3d6b7f869827a',
    messagingSenderId: '303740226831',
    projectId: 'sipho-f5a01',
    storageBucket: 'sipho-f5a01.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByD_vZ0lPWcOYF96-rT07UcHWsG47w4vQ',
    appId: '1:303740226831:ios:a34848cb0a23cd8e69827a',
    messagingSenderId: '303740226831',
    projectId: 'sipho-f5a01',
    storageBucket: 'sipho-f5a01.firebasestorage.app',
    iosBundleId: 'com.cargonomade.sipho',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyByD_vZ0lPWcOYF96-rT07UcHWsG47w4vQ',
    appId: '1:303740226831:ios:a34848cb0a23cd8e69827a',
    messagingSenderId: '303740226831',
    projectId: 'sipho-f5a01',
    storageBucket: 'sipho-f5a01.firebasestorage.app',
    iosBundleId: 'com.cargonomade.sipho',
  );
}
