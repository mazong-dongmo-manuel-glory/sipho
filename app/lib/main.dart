// Flutter entry point.
//
// The Firebase project follows the Android/iOS flavor the app was built with, so the default
// target works for every environment:
//   flutter run --flavor dev
//   flutter run --flavor staging
//   flutter build appbundle --flavor prod
// Without a flavor (or with an unknown one) a RELEASE build is PRODUCTION (sipho-prod). A DEBUG
// build without a flavor uses DEV instead: iOS has a single Xcode scheme and no flavors, so a plain
// `flutter run` there must never point a developer at production. `main_dev.dart` and
// `main_staging.dart` remain as explicit per-environment entry points (used by CI).
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
