class DashboardController < ApplicationController
  def show
    @user = Current.user
    @recent_attempts = @user.quiz_attempts.completed.recent.limit(5).includes(:quiz)
    @quizzes = Quiz.all.includes(:questions)
    @stats = {
      total_quizzes: @user.completed_quizzes_count,
      average_score: @user.average_score,
      current_streak: @user.current_streak,
      longest_streak: @user.longest_streak
    }
  end
end
