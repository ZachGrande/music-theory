require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  # Validations
  test "valid answer" do
    answer = build(:answer)
    assert answer.valid?
  end

  test "requires content" do
    answer = build(:answer, content: nil)
    assert_not answer.valid?
    assert_includes answer.errors[:content], "can't be blank"
  end

  test "requires question association" do
    answer = build(:answer, question: nil)
    assert_not answer.valid?
  end

  # Associations
  test "belongs to question" do
    question = create(:question)
    answer = create(:answer, question: question)
    assert_equal question, answer.question
  end

  test "has many user answers" do
    answer = create(:answer)
    quiz_attempt = create(:quiz_attempt, quiz: answer.question.quiz)
    create(:user_answer, answer: answer, question: answer.question, quiz_attempt: quiz_attempt)
    assert_equal 1, answer.user_answers.count
  end

  test "destroys user answers when answer is destroyed" do
    answer = create(:answer)
    quiz_attempt = create(:quiz_attempt, quiz: answer.question.quiz)
    create(:user_answer, answer: answer, question: answer.question, quiz_attempt: quiz_attempt)
    assert_difference "UserAnswer.count", -1 do
      answer.destroy
    end
  end

  # Scopes
  test "correct scope returns only correct answers" do
    question = create(:question)
    correct1 = create(:answer, question: question, correct: true)
    correct2 = create(:answer, question: question, correct: true)
    create(:answer, question: question, correct: false)

    correct_answers = question.answers.correct
    assert_equal 2, correct_answers.count
    assert_includes correct_answers, correct1
    assert_includes correct_answers, correct2
  end

  test "incorrect scope returns only incorrect answers" do
    question = create(:question)
    create(:answer, question: question, correct: true)
    incorrect1 = create(:answer, question: question, correct: false)
    incorrect2 = create(:answer, question: question, correct: false)

    incorrect_answers = question.answers.incorrect
    assert_equal 2, incorrect_answers.count
    assert_includes incorrect_answers, incorrect1
    assert_includes incorrect_answers, incorrect2
  end

  # Traits
  test "correct trait creates correct answer" do
    answer = create(:answer, :correct)
    assert answer.correct?
  end

  test "incorrect trait creates incorrect answer" do
    answer = create(:answer, :incorrect)
    assert_not answer.correct?
  end

  # Default values
  test "default correct value is false" do
    answer = create(:answer)
    assert_not answer.correct?
  end
end
