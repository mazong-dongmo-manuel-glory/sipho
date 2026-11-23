import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/home/domain/on_track.dart';

void main() {
  test('a negative remainder asks to catch up', () {
    final feedback = buildOnTrack(
      streak: 10,
      hasIncome: true,
      remainingCents: -100,
      expensesThisMonth: 8,
    );
    expect(feedback.tone, OnTrackTone.catchUp);
  });

  test('a streak of three days is on track', () {
    final feedback = buildOnTrack(
      streak: 3,
      hasIncome: true,
      remainingCents: 5000,
      expensesThisMonth: 0,
    );
    expect(feedback.tone, OnTrackTone.onTrack);
  });

  test('logging three expenses is on track even without a long streak', () {
    final feedback = buildOnTrack(
      streak: 1,
      hasIncome: false,
      remainingCents: 0,
      expensesThisMonth: 3,
    );
    expect(feedback.tone, OnTrackTone.onTrack);
  });

  test('a quiet start stays a first step', () {
    final feedback = buildOnTrack(
      streak: 0,
      hasIncome: true,
      remainingCents: 1000,
      expensesThisMonth: 1,
    );
    expect(feedback.tone, OnTrackTone.start);
  });
}
