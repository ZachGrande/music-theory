# frozen_string_literal: true

class PlatformStats
  CACHE_KEY = "platform_stats"
  CACHE_EXPIRY = 5.minutes

  def self.calculate
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_EXPIRY) do
      new.calculate
    end
  end

  def calculate
    {
      total_users: User.count,
      total_quizzes: Quiz.count,
      quizzes_completed: QuizAttempt.completed.count,
      questions_answered: UserAnswer.count,
      active_learners: User.with_active_streak.count,
      average_score: calculate_average_score
    }
  end

  private

  def calculate_average_score
    completed_attempts = QuizAttempt.completed.includes(:quiz).where.not(score: nil)
    return 0 if completed_attempts.empty?

    total_percentage = completed_attempts.sum do |attempt|
      attempt.score_percentage
    end

    (total_percentage.to_f / completed_attempts.count).round(1)
  end
end
