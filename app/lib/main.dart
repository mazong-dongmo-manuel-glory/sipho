// Flutter entry point.
//
// Environments (2 Firebase projects):
//   debug  → flavor `dev`     → project `sipho-staging` (console « sipho-dev »)
//   release → flavor `prod`   → project `sipho-f5a01`
// Explicit targets: `main_dev.dart` / `main_staging.dart` (both → sipho-staging),
// `main_prod.dart` (→ sipho-f5a01).
// Never use Firebase project ID `staging` — it does not exist on this account.
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart' show appFlavor;
import 'package:sipho/bootstrap.dart';
import 'package:sipho/core/firebase/firebase_options_dev.dart' as dev;
import 'package:sipho/core/firebase/firebase_options_prod.dart' as prod;
import 'package:sipho/core/firebase/firebase_options_staging.dart' as staging;

/// The environment to run: the build flavor, else dev in debug builds and prod in release builds.
String resolveFlavor(String? flavor, {required bool debug}) {
  switch (flavor) {
    case 'dev':
    case 'staging':
      return flavor!;
    case 'prod':
      return 'prod';
    default:
      return debug ? 'dev' : 'prod';
  }
}

void main() {
  switch (resolveFlavor(appFlavor, debug: kDebugMode)) {
    case 'dev':
      bootstrap(dev.DefaultFirebaseOptions.currentPlatform, flavor: 'dev');
    case 'staging':
      bootstrap(
        staging.DefaultFirebaseOptions.currentPlatform,
        flavor: 'staging',
      );
    default:
      bootstrap(prod.DefaultFirebaseOptions.currentPlatform, flavor: 'prod');
  }
}
