import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/auth_redirect.dart';

void main() {
  test('auth loading is not treated as logged-out', () {
    const loading = AsyncLoading<Object?>();
    expect(authIsStillLoading(loading), isTrue);
    expect(authIsLoggedIn(loading), isFalse);
    expect(
      anonymousAuthRedirect(auth: loading, location: '/home'),
      isNull,
    );
  });

  test('anonymous visitor on home goes to splash', () {
    const signedOut = AsyncData<Object?>(null);
    expect(
      anonymousAuthRedirect(auth: signedOut, location: '/home'),
      '/splash',
    );
  });

  test('anonymous visitor may stay on splash or login', () {
    const signedOut = AsyncData<Object?>(null);
    expect(
      anonymousAuthRedirect(auth: signedOut, location: '/splash'),
      isNull,
    );
    expect(
      anonymousAuthRedirect(auth: signedOut, location: '/login'),
      isNull,
    );
  });
}
