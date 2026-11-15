import 'package:sipho/features/friends/data/phone_linker.dart';

/// A [PhoneLinker] for tests: no Firebase, scripted outcomes.
class FakePhoneLinker implements PhoneLinker {
  FakePhoneLinker({this.linkedPhone, this.instant = false});

  @override
  String? linkedPhone;

  /// Whether the number is verified without typing a code (Android auto-retrieval).
  final bool instant;

  PhoneLinkFailure? failSend;
  PhoneLinkFailure? failConfirm;
  final sent = <String>[];
  final codes = <String>[];
  String? _pending;

  @override
  Future<bool> sendCode(String e164) async {
    sent.add(e164);
    final failure = failSend;
    if (failure != null) throw PhoneLinkException(failure);
    if (instant) {
      linkedPhone = e164;
      return true;
    }
    _pending = e164;
    return false;
  }

  @override
  Future<void> confirm(String smsCode) async {
    codes.add(smsCode);
    final failure = failConfirm;
    if (failure != null) throw PhoneLinkException(failure);
    linkedPhone = _pending;
  }
}
