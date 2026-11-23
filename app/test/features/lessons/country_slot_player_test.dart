import 'package:flutter_test/flutter_test.dart';
import 'package:sipho/features/lessons/domain/country_slot_player.dart';

void main() {
  test('spinner only while waiting for a country slot fill', () {
    expect(
      shouldShowCountrySlotSpinner(
        isCountrySlot: true,
        isPlayable: false,
        slotFillFailed: false,
      ),
      isTrue,
    );
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
        isCountrySlot: true,
        isPlayable: false,
        slotFillFailed: true,
      ),
      isFalse,
    );
  });

  test('AI fill requests need a real country code', () {
    expect(
      canRequestAiLessonFill(alreadyRequested: false, countryCode: 'FR'),
      isTrue,
    );
    expect(
      canRequestAiLessonFill(alreadyRequested: false, countryCode: ''),
      isFalse,
    );
    expect(
      canRequestAiLessonFill(alreadyRequested: true, countryCode: 'FR'),
      isFalse,
    );
  });
}
