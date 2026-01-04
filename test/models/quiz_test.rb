require "test_helper"

class QuizTest < ActiveSupport::TestCase
  # Validations
  test "valid quiz" do
    quiz = build(:quiz)
    assert quiz.valid?
  end

  test "requires title" do
    quiz = build(:quiz, title: nil)
    assert_not quiz.valid?
    assert_includes quiz.errors[:title], "can't be blank"
  end

  test "requires difficulty" do
    quiz = build(:quiz, difficulty: nil)
    assert_not quiz.valid?
    assert_includes quiz.errors[:difficulty], "can't be blank"
  end

  # Enum
  test "difficulty enum has correct values" do
    assert_equal({ "easy" => 0, "medium" => 1, "hard" => 2 }, Quiz.difficulties)
  end

  test "can set difficulty to easy" do
    quiz = create(:quiz, :easy)
    assert quiz.easy?
    assert_not quiz.medium?
    assert_not quiz.hard?
  end

  test "can set difficulty to medium" do
    quiz = create(:quiz, difficulty: :medium)
    assert quiz.medium?
  end

  test "can set difficulty to hard" do
    quiz = create(:quiz, :hard)
    assert quiz.hard?
  end

  # Associations
  test "has many questions" do
    quiz = create(:quiz)
    create_list(:question, 3, quiz: quiz)
    assert_equal 3, quiz.questions.count
  end

  test "has many quiz attempts" do
    quiz = create(:quiz)
    user = create(:user)
    create_list(:quiz_attempt, 2, quiz: quiz, user: user)
    assert_equal 2, quiz.quiz_attempts.count
  end

  test "destroys questions when quiz is destroyed" do
    quiz = create(:quiz)
    create(:question, quiz: quiz)
    assert_difference "Question.count", -1 do
      quiz.destroy
    end
  end

  test "destroys quiz attempts when quiz is destroyed" do
    quiz = create(:quiz)
    user = create(:user)
    create(:quiz_attempt, quiz: quiz, user: user)
    assert_difference "QuizAttempt.count", -1 do
      quiz.destroy
    end
  end

  # Instance methods
  test "question_count returns number of questions" do
    quiz = create(:quiz)
    create_list(:question, 5, quiz: quiz)
    assert_equal 5, quiz.question_count
  end

  test "question_count returns 0 when no questions" do
    quiz = create(:quiz)
    assert_equal 0, quiz.question_count
  end
end
