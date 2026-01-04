FactoryBot.define do
  factory :answer do
    question
    sequence(:content) { |n| "Answer option #{n}" }
    correct { false }

    trait :correct do
      content { "Correct answer" }
      correct { true }
    end

    trait :incorrect do
      correct { false }
    end
  end
end
