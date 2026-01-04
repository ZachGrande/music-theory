class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  scope :ordered, -> { order(created_at: :desc) }
  scope :recent, ->(days = 7) { where(created_at: days.days.ago..) }
  scope :with_active_streak, -> { where("current_streak > 0") }

  def admin?
    admin
  end

  def completed_quizzes_count
    quiz_attempts.completed.count
  end

  def average_score
    completed = quiz_attempts.completed
    return 0 if completed.empty?

    total_percentage = completed.sum do |attempt|
      attempt.score_percentage
    end
    (total_percentage.to_f / completed.count).round
  end
end
