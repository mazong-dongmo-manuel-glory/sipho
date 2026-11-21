import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations.dart';
import 'package:sipho/features/auth/presentation/auth_provider.dart';
import 'package:sipho/features/friends/domain/friend_challenge.dart';
import 'package:sipho/features/friends/presentation/friend_challenge_card.dart';

void main() {
  testWidgets('renders active friend challenge with 1v1 progress', (tester) async {
    final challenge = FriendChallenge(
      id: 'c1',
      pairId: 'p1',
      senderUid: 'me',
      receiverUid: 'friend1',
      senderName: 'Moi',
      receiverName: 'Sophie',
      title: 'Marathon Savoir',
      description: 'Termine 3 leçons financières',
      category: ChallengeCategory.learning,
      targetCount: 3,
      senderProgress: 2,
      receiverProgress: 1,
      rewardXp: 50,
      status: ChallengeStatus.active,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 5)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(
            body: FriendChallengeCard(challenge: challenge),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Marathon Savoir'), findsOneWidget);
    expect(find.text('+50 XP'), findsOneWidget);
    expect(find.text('⚔️'), findsOneWidget);
    expect(find.text('Termine 3 leçons financières'), findsOneWidget);
  });
}
