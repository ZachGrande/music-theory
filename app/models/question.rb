class Question < ApplicationRecord
  belongs_to :quiz
  has_many :answers, dependent: :destroy
  has_many :user_answers, dependent: :destroy

  enum :difficulty, { easy: 0, medium: 1, hard: 2 }

  validates :content, presence: true
  validates :difficulty, presence: true
  validates :topic, presence: true

  TOPICS = %w[intervals chords scales key_signatures notes rhythm].freeze

  def correct_answer
    answers.find_by(correct: true)
  end
end
