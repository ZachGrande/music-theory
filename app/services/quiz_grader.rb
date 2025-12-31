class QuizGrader
  def initialize(quiz_attempt)
    @quiz_attempt = quiz_attempt
  end

  def grade!
    score = calculate_score
    @quiz_attempt.update!(
      score: score,
      completed_at: Time.current
    )

    update_streak
    score
  end

  private

  def calculate_score
    @quiz_attempt.user_answers.joins(:answer).where(answers: { correct: true }).count
  end

  def update_streak
    StreakTracker.new(@quiz_attempt.user).update!
  end
end
