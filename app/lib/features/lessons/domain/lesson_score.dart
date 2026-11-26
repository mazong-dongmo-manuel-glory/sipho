/// Mistakes made on the true/false and simulation steps, carried to the quiz.
///
/// A lesson is perfect only when every checked step was right. Skipping a step
/// is not a mistake; a wrong answer is, and it stays wrong after the route changes.
int lessonMistakesAfterAnswer({
  required int priorMistakes,
  required bool answered,
  required bool correct,
}) {
  final prior = priorMistakes < 0 ? 0 : priorMistakes;
  if (!answered || correct) return prior;
  return prior + 1;
}

/// Score sent to `completeLesson`. 100 is the perfect-completion reward.
int lessonCompletionScore({
  required int priorMistakes,
  required bool quizEverWrong,
}) {
  if (priorMistakes <= 0 && !quizEverWrong) return 100;
  return 70;
}
