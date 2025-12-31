class Answer < ApplicationRecord
  belongs_to :question
  has_many :user_answers, dependent: :destroy

  validates :content, presence: true

  scope :correct, -> { where(correct: true) }
  scope :incorrect, -> { where(correct: false) }
end
