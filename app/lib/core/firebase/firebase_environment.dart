import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Marker used by the generated option files until `flutterfire configure` has been run for
/// that environment.
const kUnconfiguredFirebaseValue = 'REPLACE_ME';

/// Firebase project behind the `dev` flavor. No other flavor may ever point at it.
const kDevFirebaseProjectId = 'sipho-f5a01';

const kFirebaseFlavors = <String>['dev', 'staging', 'prod'];

/// Fails fast when a flavor is wired to a missing or wrong Firebase project, so a production
/// or staging build can never silently talk to the development project (and its data).
void assertFirebaseConfigured(
  FirebaseOptions options, {
  required String flavor,
}) {
  if (!kFirebaseFlavors.contains(flavor)) {
    throw StateError('Unknown flavor "$flavor". Expected one of $kFirebaseFlavors.');
  }

  final unconfigured = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
  ].any((value) => value.isEmpty || value == kUnconfiguredFirebaseValue);
  if (unconfigured) {
    throw StateError(
      'Firebase is not configured for the "$flavor" flavor. '
      'Run `flutterfire configure --project=sipho-$flavor '
      '--out=lib/core/firebase/firebase_options_$flavor.dart` '
      'and add the matching google-services.json under android/app/src/$flavor/.',
    );
  }

  if (flavor != 'dev' && options.projectId == kDevFirebaseProjectId) {
    throw StateError(
      'The "$flavor" flavor points at the dev Firebase project '
      '($kDevFirebaseProjectId). Each flavor needs its own project.',
    );
  }
}
