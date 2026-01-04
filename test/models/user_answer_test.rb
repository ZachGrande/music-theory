require "test_helper"

class UserAnswerTest < ActiveSupport::TestCase
  setup do
    @quiz = create(:quiz)
    @question = create(:question, quiz: @quiz)
    @answer = create(:answer, question: @question)
    @quiz_attempt = create(:quiz_attempt, quiz: @quiz)
  end

  # Validations
  test "valid user answer" do
    user_answer = build(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    assert user_answer.valid?
  end

  test "requires quiz attempt association" do
    user_answer = build(:user_answer, quiz_attempt: nil, question: @question, answer: @answer)
    assert_not user_answer.valid?
  end

  test "requires question association" do
    user_answer = build(:user_answer, quiz_attempt: @quiz_attempt, question: nil, answer: @answer)
    assert_not user_answer.valid?
  end

  test "requires answer association" do
    user_answer = build(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: nil)
    assert_not user_answer.valid?
  end

  test "enforces uniqueness of question per quiz attempt" do
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    duplicate = build(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:question_id], "has already been taken"
  end

  test "allows same question in different quiz attempts" do
    other_attempt = create(:quiz_attempt, quiz: @quiz)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    other_user_answer = build(:user_answer, quiz_attempt: other_attempt, question: @question, answer: @answer)

    assert other_user_answer.valid?
  end

  # Associations
  test "belongs to quiz attempt" do
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    assert_equal @quiz_attempt, user_answer.quiz_attempt
  end

  test "belongs to question" do
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    assert_equal @question, user_answer.question
  end

  test "belongs to answer" do
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: @answer)
    assert_equal @answer, user_answer.answer
  end

  # Instance methods
  test "correct? returns true when answer is correct" do
    correct_answer = create(:answer, :correct, question: @question)
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: correct_answer)

    assert user_answer.correct?
  end

  test "correct? returns false when answer is incorrect" do
    incorrect_answer = create(:answer, question: @question, correct: false)
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: incorrect_answer)

    assert_not user_answer.correct?
  end

  test "correct? delegates to answer" do
    correct_answer = create(:answer, :correct, question: @question)
    user_answer = create(:user_answer, quiz_attempt: @quiz_attempt, question: @question, answer: correct_answer)

    assert_equal correct_answer.correct?, user_answer.correct?
  end
end
