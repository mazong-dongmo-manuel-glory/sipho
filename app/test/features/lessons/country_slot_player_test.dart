import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/country_slot_player.dart';

void main() {
  group('shouldShowCountrySlotSpinner', () {
    test('spins only while a country slot is still filling', () {
      expect(
        shouldShowCountrySlotSpinner(
          isCountrySlot: true,
          isPlayable: false,
          slotFillFailed: false,
        ),
        isTrue,
      );
    });

    test('stops spinning after fill failure (not-found instead)', () {
      expect(
        shouldShowCountrySlotSpinner(
          isCountrySlot: true,
          isPlayable: false,
          slotFillFailed: true,
        ),
        isFalse,
      );
    });

    test('does not spin for playable or non-slot lessons', () {
      expect(
        shouldShowCountrySlotSpinner(
          isCountrySlot: true,
          isPlayable: true,
          slotFillFailed: false,
        ),
        isFalse,
      );
      expect(
        shouldShowCountrySlotSpinner(
          isCountrySlot: false,
          isPlayable: false,
          slotFillFailed: false,
        ),
        isFalse,
      );
    });
  });

  group('canRequestAiLessonFill', () {
    test('waits for a non-empty countryCode before requesting', () {
      expect(
        canRequestAiLessonFill(alreadyRequested: false, countryCode: null),
        isFalse,
      );
      expect(
        canRequestAiLessonFill(alreadyRequested: false, countryCode: '  '),
        isFalse,
      );
      expect(
        canRequestAiLessonFill(alreadyRequested: false, countryCode: 'CA'),
        isTrue,
      );
    });

    test('does not re-request after the one-shot flag is set', () {
      expect(
        canRequestAiLessonFill(alreadyRequested: true, countryCode: 'CA'),
        isFalse,
      );
    });
  });
}
