import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/core/firebase/firebase_environment.dart';
import 'package:sipho/core/firebase/firebase_options_dev.dart' as dev;
import 'package:sipho/core/firebase/firebase_options_prod.dart' as prod;
import 'package:sipho/core/firebase/firebase_options_staging.dart' as staging;

FirebaseOptions _options(String projectId) => FirebaseOptions(
      apiKey: 'AIzaFakeKey',
      appId: '1:1:android:abc',
      messagingSenderId: '1',
      projectId: projectId,
    );

void main() {
  test('prod options point at sipho-f5a01 and pass assert', () {
    for (final options in [
      prod.DefaultFirebaseOptions.android,
      prod.DefaultFirebaseOptions.ios,
    ]) {
      expect(options.projectId, kProdFirebaseProjectId);
      expect(
        () => assertFirebaseConfigured(options, flavor: 'prod'),
        returnsNormally,
      );
    }
  });

  test('dev and staging option files target the staging project id', () {
    for (final options in [
      dev.DefaultFirebaseOptions.android,
      dev.DefaultFirebaseOptions.ios,
      staging.DefaultFirebaseOptions.android,
      staging.DefaultFirebaseOptions.ios,
    ]) {
      expect(options.projectId, kStagingFirebaseProjectId);
    }
  });

  test('dev/staging options for sipho-staging pass assert when configured', () {
    expect(
      () => assertFirebaseConfigured(
        staging.DefaultFirebaseOptions.android,
        flavor: 'staging',
      ),
      returnsNormally,
    );
    expect(
      () => assertFirebaseConfigured(
        staging.DefaultFirebaseOptions.ios,
        flavor: 'staging',
      ),
      returnsNormally,
    );
    expect(
      () => assertFirebaseConfigured(
        dev.DefaultFirebaseOptions.android,
        flavor: 'dev',
      ),
      returnsNormally,
    );
  });

  test('an unconfigured flavor placeholder refuses to start', () {
    const placeholder = FirebaseOptions(
      apiKey: kUnconfiguredFirebaseValue,
      appId: kUnconfiguredFirebaseValue,
      messagingSenderId: kUnconfiguredFirebaseValue,
      projectId: kStagingFirebaseProjectId,
    );
    expect(
      () => assertFirebaseConfigured(placeholder, flavor: 'staging'),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('flutterfire configure --project=$kStagingFirebaseProjectId'),
      )),
    );
  });

  test('wrong project for a flavor is rejected', () {
    expect(
      () => assertFirebaseConfigured(_options('sipho-other'), flavor: 'prod'),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('must use "$kProdFirebaseProjectId"'),
      )),
    );
    expect(
      () => assertFirebaseConfigured(
        _options(kStagingFirebaseProjectId),
        flavor: 'prod',
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      () => assertFirebaseConfigured(
        _options(kProdFirebaseProjectId),
        flavor: 'staging',
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      () => assertFirebaseConfigured(
        _options(kProdFirebaseProjectId),
        flavor: 'prod',
      ),
      returnsNormally,
    );
    expect(
      () => assertFirebaseConfigured(
        _options(kStagingFirebaseProjectId),
        flavor: 'dev',
      ),
      returnsNormally,
    );
  });

  test('flavor → project map matches the two-environment architecture', () {
    expect(kExpectedProjectByFlavor['dev'], kStagingFirebaseProjectId);
    expect(kExpectedProjectByFlavor['staging'], kStagingFirebaseProjectId);
    expect(kExpectedProjectByFlavor['prod'], kProdFirebaseProjectId);
    expect(kDevFirebaseProjectId, kStagingFirebaseProjectId);
    expect(kFirebaseProjectId, kProdFirebaseProjectId);
  });
}
