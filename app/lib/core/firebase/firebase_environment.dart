import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Marker used by option files until `flutterfire configure` has been run.
const kUnconfiguredFirebaseValue = 'REPLACE_ME';

/// Production Firebase project (stores / release builds).
const kProdFirebaseProjectId = 'sipho-f5a01';

/// Dev / QA Firebase project (debug, `main_dev`, `main_staging`).
///
/// **Project ID is `sipho-staging`** (console display name: « sipho-dev »).
/// There is **no** Firebase project whose ID is simply `staging` on the Sipho
/// account — do not use `--project staging`.
const kStagingFirebaseProjectId = 'sipho-staging';

/// Alias kept for older call sites / tests: production project id.
const kFirebaseProjectId = kProdFirebaseProjectId;

/// Alias: the Dart "dev" flavor targets the sipho-staging Firebase project.
const kDevFirebaseProjectId = kStagingFirebaseProjectId;

const kFirebaseFlavors = <String>['dev', 'staging', 'prod'];

/// Expected `projectId` for each Dart flavor / entry point.
const kExpectedProjectByFlavor = <String, String>{
  'dev': kStagingFirebaseProjectId,
  'staging': kStagingFirebaseProjectId,
  'prod': kProdFirebaseProjectId,
};

/// Fails fast when a flavor's Firebase options are still placeholders
/// or point at the wrong project for that flavor.
void assertFirebaseConfigured(
  FirebaseOptions options, {
  required String flavor,
}) {
  if (!kFirebaseFlavors.contains(flavor)) {
    throw StateError(
        'Unknown flavor "$flavor". Expected one of $kFirebaseFlavors.');
  }

  final expectedProjectId = kExpectedProjectByFlavor[flavor]!;

  final unconfigured = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
    options.projectId,
  ].any((value) => value.isEmpty || value == kUnconfiguredFirebaseValue);
  if (unconfigured) {
    throw StateError(
      'Firebase is not configured for the "$flavor" flavor. '
      'Run flutterfire configure --project=$expectedProjectId '
      '--out=lib/core/firebase/firebase_options_$flavor.dart '
      '(packages: com.cargonomade.sipho'
      '${flavor == 'prod' ? '' : '.staging'}).',
    );
  }

  if (options.projectId != expectedProjectId) {
    throw StateError(
      'The "$flavor" flavor points at "${options.projectId}", '
      'but it must use "$expectedProjectId" '
      '(prod=$kProdFirebaseProjectId, '
      'dev/QA=$kStagingFirebaseProjectId a.k.a. console « sipho-dev »).',
    );
  }
}
