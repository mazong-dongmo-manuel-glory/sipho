import 'package:freezed_annotation/freezed_annotation.dart';

part 'quest.freezed.dart';
part 'quest.g.dart';

@freezed
class Quest with _$Quest {
  const factory Quest({
    required String id,
    required String templateId,
    required String type, // daily | weekly | monthly
    required int progress,
    required int target,
    required int rewardXp,
    String? rewardChest,
    DateTime? expiresAt,
    @Default('active') String status, // active | completed | claimed
  }) = _Quest;

  factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
}

