// Generated for Firebase project sipho-staging (console « sipho-dev »).
// Packages: com.cargonomade.sipho.staging
// Do NOT point this file at sipho-f5a01.
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
    apiKey: 'AIzaSyCPJR7Qa88aQyFPdirP2aogwUneYZqrzuA',
    appId: '1:246057291906:android:84b432cee049dbb620a49b',
    messagingSenderId: '246057291906',
    projectId: 'sipho-staging',
    storageBucket: 'sipho-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOeRL_mb0pQHc25VB816dPitNqUK9R0E0',
    appId: '1:246057291906:ios:09e83b31378221a620a49b',
    messagingSenderId: '246057291906',
    projectId: 'sipho-staging',
    storageBucket: 'sipho-staging.firebasestorage.app',
    iosClientId: '246057291906-8s8j9qik7m29iff7btp8rbmvt6m2pihc.apps.googleusercontent.com',
    iosBundleId: 'com.cargonomade.sipho.staging',
  );
}
