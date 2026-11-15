import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/app/l10n/app_localizations_en.dart';
import 'package:sipho/app/l10n/app_localizations_fr.dart';
import 'package:sipho/features/gamification/domain/badges.dart';

void main() {
  test('newBadges lists only the ones not owned before', () {
    expect(newBadges([], ['a', 'b']), ['a', 'b']);
    expect(newBadges(['a'], ['a', 'b']), ['b']);
    expect(newBadges(['a', 'b'], ['a', 'b']), isEmpty);
    expect(newBadges(['a', 'b'], ['a']), isEmpty);
  });

  test('every badge has a name and a hint in both languages', () {
    for (final l10n in [AppLocalizationsEn(), AppLocalizationsFr()]) {
      for (final badge in kBadges) {
        expect(badgeTitle(l10n, badge.id), isNot(badge.id));
        expect(badgeHint(l10n, badge.id), isNotEmpty);
      }
    }
  });

  test('an unknown badge id from a newer server falls back to the id', () {
    expect(badgeTitle(AppLocalizationsEn(), 'future_badge'), 'future_badge');
    expect(badgeHint(AppLocalizationsEn(), 'future_badge'), '');
  });

  test('badge ids are unique and match the server (shared/badges.ts)', () {
    final ids = [for (final badge in kBadges) badge.id];
    expect(ids.toSet().length, ids.length);

    final file = File('../functions/src/shared/badges.ts');
    final lessonPath = File('../functions/src/shared/lessonPath.ts');
    if (!file.existsSync() || !lessonPath.existsSync()) {
      markTestSkipped('functions/ not found from the app directory');
      return;
    }
    final source = file.readAsStringSync();
    final rules = source.substring(source.indexOf('BADGE_RULES'));
    final unitIds = RegExp(r'id:\s*"(unit_\d+)"')
        .allMatches(lessonPath.readAsStringSync())
        .map((m) => m.group(1)!)
        .toList();
    final serverIds = <String>[];
    for (final m
        in RegExp(r'id:\s*"(\w+)"|\.\.\.UNIT_BADGES').allMatches(rules)) {
      if (m.group(1) != null) {
        serverIds.add(m.group(1)!);
      } else {
        serverIds.addAll(unitIds);
      }
    }
    expect(ids, serverIds);
  });
}
