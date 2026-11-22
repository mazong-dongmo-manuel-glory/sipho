import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cold-start auth: while the stream is still loading, do not redirect to splash/login.
bool authIsStillLoading(AsyncValue<Object?> auth) => auth.isLoading;

/// Logged-in for redirect purposes (never true while [auth] is loading).
bool authIsLoggedIn(AsyncValue<Object?> auth) {
  if (auth.isLoading) return false;
  return auth.valueOrNull != null;
}

/// Where to send an anonymous visitor. Returns null when auth is still loading
/// (stay on the current route — avoids a splash flash at cold start).
String? anonymousAuthRedirect({
  required AsyncValue<Object?> auth,
  required String location,
}) {
  if (authIsStillLoading(auth)) return null;
  if (authIsLoggedIn(auth)) return null;
  final onboarding = location.startsWith('/onboarding');
  final splash = location.startsWith('/splash');
  final login = location.startsWith('/login');
  if (!onboarding && !splash && !login) return '/splash';
  return null;
}
