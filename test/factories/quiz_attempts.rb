FactoryBot.define do
  factory :quiz_attempt do
    user
    quiz
    score { nil }
    completed_at { nil }

    trait :completed do
      score { 3 }
      completed_at { Time.current }
    end

    trait :with_score do
      transient do
        correct_count { 2 }
        total_questions { 5 }
      end

      score { correct_count }
      completed_at { Time.current }

      after(:create) do |attempt, evaluator|
        quiz = attempt.quiz

        # Create questions if needed
        questions_needed = evaluator.total_questions - quiz.questions.count
        create_list(:question, questions_needed, :with_answers, quiz: quiz) if questions_needed > 0

        # Create user answers
        quiz.questions.reload.each_with_index do |question, index|
          answer = if index < evaluator.correct_count
                     question.answers.find_by(correct: true) || create(:answer, :correct, question: question)
          else
                     question.answers.find_by(correct: false) || create(:answer, question: question)
          end
          create(:user_answer, quiz_attempt: attempt, question: question, answer: answer)
        end
      end
    end
  end
end
