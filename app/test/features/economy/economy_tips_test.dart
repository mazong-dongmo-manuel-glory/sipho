import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/economy/data/economy_repository.dart';
import 'package:sipho/features/economy/domain/economy_tips.dart';

void main() {
  group('Economy tips catalog & randomization', () {
    test('contains at least 10 varied tips across categories', () {
      expect(kEconomyTips.length, greaterThanOrEqualTo(10));
      final categories = kEconomyTips.map((t) => t.category).toSet();
      expect(categories.length, greaterThanOrEqualTo(4));
    });

    test('every tip has non-empty FR and EN titles, bodies and action steps', () {
      for (final tip in kEconomyTips) {
        expect(tip.title.fr.trim(), isNotEmpty, reason: tip.id);
        expect(tip.title.en.trim(), isNotEmpty, reason: tip.id);
        expect(tip.body.fr.trim(), isNotEmpty, reason: tip.id);
        expect(tip.body.en.trim(), isNotEmpty, reason: tip.id);
        expect(tip.actionTip.fr.trim(), isNotEmpty, reason: tip.id);
        expect(tip.actionTip.en.trim(), isNotEmpty, reason: tip.id);
        expect(tip.emoji.trim(), isNotEmpty, reason: tip.id);
        expect(tip.source.trim(), isNotEmpty, reason: tip.id);
      }
    });

    test('dailyEconomyTip provides deterministic tip for the same day', () {
      final day1 = DateTime(2026, 11, 19, 10, 0);
      final day2 = DateTime(2026, 11, 19, 18, 30);
      expect(dailyEconomyTip(day1).id, dailyEconomyTip(day2).id);
    });

    test('pickRandomEconomyTip changes tip when excluding current', () {
      final current = kEconomyTips.first;
      final random = Random(42);
      final next = pickRandomEconomyTip(
        currentId: current.id,
        random: random,
      );
      expect(next.id, isNot(current.id));
    });

    test('pickRandomEconomyTip respects category filter', () {
      final tip = pickRandomEconomyTip(
        category: EconomyTipCategory.security,
        random: Random(1),
      );
      expect(tip.category, EconomyTipCategory.security);
    });
  });

  group('Economy data fallbacks by country', () {
    test('defaultEconomyData provides realistic benchmarks for CA, FR, CM, CI, SN', () {
      for (final code in ['CA', 'FR', 'CM', 'CI', 'SN', 'GENERIC']) {
        final data = EconomyRepository.defaultEconomyData(code);
        expect(data.countryCode, code);
        expect(data.indicators['inflation']?.value, greaterThan(0));
        expect(data.indicators['policy_rate']?.value, greaterThan(0));
        expect(data.summary?['fr']?.trim(), isNotEmpty);
        expect(data.summary?['en']?.trim(), isNotEmpty);
      }
    });
  });
}
