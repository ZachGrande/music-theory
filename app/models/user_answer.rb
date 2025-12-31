class UserAnswer < ApplicationRecord
  belongs_to :quiz_attempt
  belongs_to :question
  belongs_to :answer

  validates :question_id, uniqueness: { scope: :quiz_attempt_id }

  def correct?
    answer.correct?
  end
end
