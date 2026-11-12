import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class SiphoUser with _$SiphoUser {
  const factory SiphoUser({
    required String uid,
    required String email,
    required String displayName,
    @Default('') String photoUrl,
    @Default('CAD') String currency,
    @Default('CA') String countryCode,
    @Default('en') String locale,
    @Default(0) int streakDays,
    @Default(0) int seeds,
    @Default(1) int level,
    @Default(0) int totalXp,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) = _SiphoUser;

  factory SiphoUser.fromJson(Map<String, dynamic> json) =>
      _$SiphoUserFromJson(json);
}
