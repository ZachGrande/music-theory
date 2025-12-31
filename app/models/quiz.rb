class Quiz < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :title, presence: true
  validates :difficulty, presence: true

  def question_count
    questions.count
  end
end
