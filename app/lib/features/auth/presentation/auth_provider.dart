import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<User?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  @override
  AsyncValue<User?> build() => const AsyncValue.data(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithGoogle()
          .then((cred) => cred?.user),
    );
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(authRepositoryProvider)
          .signInWithApple()
          .then((cred) => cred?.user),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
