import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/main.dart';

void main() {
  group('resolveFlavor', () {
    test('an explicit flavor always wins', () {
      for (final debug in [true, false]) {
        expect(resolveFlavor('dev', debug: debug), 'dev');
        expect(resolveFlavor('staging', debug: debug), 'staging');
        expect(resolveFlavor('prod', debug: debug), 'prod');
      }
    });

    test('no flavor in a debug build means dev, never production', () {
      expect(resolveFlavor(null, debug: true), 'dev');
      expect(resolveFlavor('whatever', debug: true), 'dev');
    });

    test('no flavor in a release build stays production', () {
      expect(resolveFlavor(null, debug: false), 'prod');
      expect(resolveFlavor('whatever', debug: false), 'prod');
    });
  });
}
