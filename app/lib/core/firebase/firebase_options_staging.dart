// Firebase options for the staging entry (`lib/main_staging.dart`).
// Same Firebase project as dev/prod (`sipho-f5a01`) for now.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    iosClientId:
        '303740226831-pcttvf5iu8bkemhhnn42thfbsv0f19jq.apps.googleusercontent.com',
    iosBundleId: 'com.cargonomade.sipho',
  );
}
