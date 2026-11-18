import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Marker used by option files until `flutterfire configure` has been run.
const kUnconfiguredFirebaseValue = 'REPLACE_ME';

/// The only Firebase project Sipho uses today (dev and release share it).
const kFirebaseProjectId = 'sipho-f5a01';

/// Kept for older comments / checks that still say "dev project".
const kDevFirebaseProjectId = kFirebaseProjectId;

const kFirebaseFlavors = <String>['dev', 'staging', 'prod'];

/// Fails fast when a flavor's Firebase options are still placeholders.
void assertFirebaseConfigured(
  FirebaseOptions options, {
  required String flavor,
}) {
  if (!kFirebaseFlavors.contains(flavor)) {
    throw StateError(
        'Unknown flavor "$flavor". Expected one of $kFirebaseFlavors.');
  }

  final unconfigured = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
  ].any((value) => value.isEmpty || value == kUnconfiguredFirebaseValue);
  if (unconfigured) {
    throw StateError(
      'Firebase is not configured for the "$flavor" flavor. '
      'Point firebase_options_$flavor.dart at $kFirebaseProjectId '
      '(or run flutterfire configure for a dedicated project later).',
    );
  }

  if (options.projectId != kFirebaseProjectId) {
    throw StateError(
      'The "$flavor" flavor points at "${options.projectId}", but Sipho '
      'currently uses a single Firebase project ($kFirebaseProjectId).',
    );
  }
}
