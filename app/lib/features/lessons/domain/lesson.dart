import 'package:freezed_annotation/freezed_annotation.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@freezed
class LessonStep with _$LessonStep {
  const factory LessonStep({
    required String type, // story | quiz | simulation
    String? siphoEmotion,
    required Map<String, String> text,
    Map<String, String>? question,
    List<Map<String, dynamic>>? options,
    Map<String, String>? explanation,
  }) = _LessonStep;

  factory LessonStep.fromJson(Map<String, dynamic> json) =>
      _$LessonStepFromJson(json);
}

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required int unit,
    required int order,
    required List<String> countries,
    required Map<String, String> title,
    required List<LessonStep> steps,
    @Default(20) int rewardXp,
    @Default(5) int rewardGems,
    @Default(1) int version,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}
