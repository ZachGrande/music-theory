FactoryBot.define do
  factory :quiz do
    sequence(:title) { |n| "Music Theory Quiz #{n}" }
    description { "Test your knowledge of music theory concepts" }
    difficulty { :medium }
    category { "theory" }

    trait :easy do
      difficulty { :easy }
    end

    trait :hard do
      difficulty { :hard }
    end

    trait :with_questions do
      transient do
        question_count { 3 }
      end

      after(:create) do |quiz, evaluator|
        create_list(:question, evaluator.question_count, :with_answers, quiz: quiz)
      end
    end
  end
end
