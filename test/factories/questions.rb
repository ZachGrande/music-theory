FactoryBot.define do
  factory :question do
    quiz
    sequence(:content) { |n| "What is the #{n}th note of the C major scale?" }
    difficulty { :medium }
    topic { Question::TOPICS.sample }

    trait :easy do
      difficulty { :easy }
    end

    trait :hard do
      difficulty { :hard }
    end

    trait :intervals do
      topic { "intervals" }
      content { "What interval is from C to G?" }
    end

    trait :chords do
      topic { "chords" }
      content { "What notes make up a C major chord?" }
    end

    trait :with_answers do
      after(:create) do |question|
        create(:answer, :correct, question: question)
        create_list(:answer, 3, question: question)
      end
    end
  end
end
