import 'package:freezed_annotation/freezed_annotation.dart';

part 'money.freezed.dart';

@freezed
class Money with _$Money {
  // ignore: unused_element
  const Money._();
  const factory Money({
    required int cents,
    required String currency,
  }) = _Money;

  static const Money zero = Money(cents: 0, currency: 'CAD');

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(cents: cents + other.cents, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(cents: cents - other.cents, currency: currency);
  }

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;
  double get amount => cents / 100.0;

  Money abs() => Money(cents: cents.abs(), currency: currency);

  /// Returns cents clamped to [min, max].
  Money clamp(int minCents, int maxCents) =>
      Money(cents: cents.clamp(minCents, maxCents), currency: currency);
}
