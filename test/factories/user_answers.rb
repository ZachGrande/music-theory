FactoryBot.define do
  factory :user_answer do
    quiz_attempt
    question
    answer

    trait :correct do
      after(:build) do |user_answer|
        user_answer.answer = create(:answer, :correct, question: user_answer.question)
      end
    end

    trait :incorrect do
      after(:build) do |user_answer|
        user_answer.answer = create(:answer, :incorrect, question: user_answer.question)
      end
    end
  end
end
