class QuizAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :quiz
  has_many :user_answers, dependent: :destroy

  scope :completed, -> { where.not(completed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def completed?
    completed_at.present?
  end

  def total_questions
    quiz.questions.count
  end

  def correct_answers_count
    user_answers.joins(:answer).where(answers: { correct: true }).count
  end

  def score_percentage
    return 0 if total_questions.zero?
    (score.to_f / total_questions * 100).round
  end
end
