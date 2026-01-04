# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def show
      @stats = {
        total_users: User.count,
        new_users_this_week: User.recent(7).count,
        total_quiz_attempts: QuizAttempt.count,
        completed_quiz_attempts: QuizAttempt.completed.count,
        average_score: calculate_average_score,
        users_with_active_streak: User.with_active_streak.count,
        total_quizzes: Quiz.count
      }

      @recent_users = User.ordered.limit(5)
      @recent_attempts = QuizAttempt.completed
                                    .includes(:user, :quiz)
                                    .recent
                                    .limit(10)
    end

    private

    def calculate_average_score
      completed = QuizAttempt.completed
      return 0 if completed.empty?

      total = completed.sum do |attempt|
        attempt.score_percentage
      end
      (total.to_f / completed.count).round
    end
  end
end
