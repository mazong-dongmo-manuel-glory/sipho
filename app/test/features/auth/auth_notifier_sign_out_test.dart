import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/auth/data/auth_repository.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  bool signedOut = false;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Stream<User?> get authStateChanges => const Stream.empty();
}

void main() {
  test('AuthNotifier.signOut clears notifier state to signed-out', () async {
    final fake = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fake),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authNotifierProvider.notifier);
    await notifier.signOut();

    expect(fake.signedOut, isTrue);
    final state = container.read(authNotifierProvider);
    expect(state.hasValue, isTrue);
    expect(state.valueOrNull, isNull);
  });
}
