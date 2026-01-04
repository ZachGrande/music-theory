FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    current_streak { 0 }
    longest_streak { 0 }
    last_quiz_date { nil }

    trait :admin do
      admin { true }
    end

    trait :with_streak do
      current_streak { 5 }
      longest_streak { 10 }
      last_quiz_date { Date.current }
    end

    trait :streak_yesterday do
      current_streak { 3 }
      longest_streak { 3 }
      last_quiz_date { Date.current - 1.day }
    end

    trait :streak_broken do
      current_streak { 5 }
      longest_streak { 5 }
      last_quiz_date { Date.current - 3.days }
    end
  end
end
