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
  test('dev flavor is configured and points at the dev project', () {
    for (final options in [dev.DefaultFirebaseOptions.android, dev.DefaultFirebaseOptions.ios]) {
      expect(options.projectId, kDevFirebaseProjectId);
      expect(() => assertFirebaseConfigured(options, flavor: 'dev'), returnsNormally);
    }
  });

  test('staging and prod never share the dev Firebase project', () {
    final all = <String, List<FirebaseOptions>>{
      'staging': [
        staging.DefaultFirebaseOptions.android,
        staging.DefaultFirebaseOptions.ios,
      ],
      'prod': [
        prod.DefaultFirebaseOptions.android,
        prod.DefaultFirebaseOptions.ios,
      ],
    };
    all.forEach((flavor, options) {
      for (final o in options) {
        expect(o.projectId, isNot(kDevFirebaseProjectId), reason: flavor);
        expect(o.projectId, 'sipho-$flavor');
      }
    });
  });

  test('an unconfigured flavor refuses to start instead of falling back to dev', () {
    expect(
      () => assertFirebaseConfigured(
        staging.DefaultFirebaseOptions.android,
        flavor: 'staging',
      ),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('flutterfire configure --project=sipho-staging'),
      )),
    );
    expect(
      () => assertFirebaseConfigured(prod.DefaultFirebaseOptions.ios, flavor: 'prod'),
      throwsStateError,
    );
  });

  test('a configured prod flavor is accepted, but not if it targets the dev project', () {
    expect(
      () => assertFirebaseConfigured(_options('sipho-prod'), flavor: 'prod'),
      returnsNormally,
    );
    expect(
      () => assertFirebaseConfigured(_options(kDevFirebaseProjectId), flavor: 'prod'),
      throwsA(isA<StateError>()
          .having((e) => e.message, 'message', contains('dev Firebase project'))),
    );
    expect(
      () => assertFirebaseConfigured(_options('sipho-staging'), flavor: 'qa'),
      throwsStateError,
    );
  });
}
