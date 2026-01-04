require "test_helper"

class QuizAttemptTest < ActiveSupport::TestCase
  # Validations
  test "valid quiz attempt" do
    quiz_attempt = build(:quiz_attempt)
    assert quiz_attempt.valid?
  end

  test "requires user association" do
    quiz_attempt = build(:quiz_attempt, user: nil)
    assert_not quiz_attempt.valid?
  end

  test "requires quiz association" do
    quiz_attempt = build(:quiz_attempt, quiz: nil)
    assert_not quiz_attempt.valid?
  end

  # Associations
  test "belongs to user" do
    user = create(:user)
    quiz_attempt = create(:quiz_attempt, user: user)
    assert_equal user, quiz_attempt.user
  end

  test "belongs to quiz" do
    quiz = create(:quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz)
    assert_equal quiz, quiz_attempt.quiz
  end

  test "has many user answers" do
    quiz_attempt = create(:quiz_attempt)
    question1 = create(:question, quiz: quiz_attempt.quiz)
    question2 = create(:question, quiz: quiz_attempt.quiz)
    question3 = create(:question, quiz: quiz_attempt.quiz)
    answer1 = create(:answer, question: question1)
    answer2 = create(:answer, question: question2)
    answer3 = create(:answer, question: question3)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question1, answer: answer1)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question2, answer: answer2)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question3, answer: answer3)
    assert_equal 3, quiz_attempt.user_answers.count
  end

  test "destroys user answers when quiz attempt is destroyed" do
    quiz_attempt = create(:quiz_attempt)
    question = create(:question, quiz: quiz_attempt.quiz)
    answer = create(:answer, question: question)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question, answer: answer)
    assert_difference "UserAnswer.count", -1 do
      quiz_attempt.destroy
    end
  end

  # Scopes
  test "completed scope returns only completed attempts" do
    user = create(:user)
    quiz = create(:quiz)
    completed = create(:quiz_attempt, :completed, user: user, quiz: quiz)
    create(:quiz_attempt, user: user, quiz: quiz) # incomplete

    assert_includes user.quiz_attempts.completed, completed
    assert_equal 1, user.quiz_attempts.completed.count
  end

  test "recent scope orders by created_at descending" do
    user = create(:user)
    quiz = create(:quiz)
    old_attempt = create(:quiz_attempt, user: user, quiz: quiz, created_at: 2.days.ago)
    new_attempt = create(:quiz_attempt, user: user, quiz: quiz, created_at: 1.day.ago)

    recent = user.quiz_attempts.recent.to_a
    assert_equal new_attempt, recent.first
    assert_equal old_attempt, recent.last
  end

  # Instance methods
  test "completed? returns true when completed_at is present" do
    quiz_attempt = create(:quiz_attempt, :completed)
    assert quiz_attempt.completed?
  end

  test "completed? returns false when completed_at is nil" do
    quiz_attempt = create(:quiz_attempt)
    assert_not quiz_attempt.completed?
  end

  test "total_questions returns count of quiz questions" do
    quiz = create(:quiz)
    create_list(:question, 5, quiz: quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz)
    assert_equal 5, quiz_attempt.total_questions
  end

  test "total_questions returns 0 when quiz has no questions" do
    quiz = create(:quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz)
    assert_equal 0, quiz_attempt.total_questions
  end

  test "correct_answers_count returns count of correct user answers" do
    quiz = create(:quiz)
    question1 = create(:question, quiz: quiz)
    question2 = create(:question, quiz: quiz)
    correct_answer1 = create(:answer, :correct, question: question1)
    incorrect_answer2 = create(:answer, question: question2)

    quiz_attempt = create(:quiz_attempt, quiz: quiz)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question1, answer: correct_answer1)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question2, answer: incorrect_answer2)

    assert_equal 1, quiz_attempt.correct_answers_count
  end

  test "correct_answers_count returns 0 when no correct answers" do
    quiz = create(:quiz)
    question = create(:question, quiz: quiz)
    incorrect_answer = create(:answer, question: question, correct: false)

    quiz_attempt = create(:quiz_attempt, quiz: quiz)
    create(:user_answer, quiz_attempt: quiz_attempt, question: question, answer: incorrect_answer)

    assert_equal 0, quiz_attempt.correct_answers_count
  end

  test "score_percentage calculates correct percentage" do
    quiz = create(:quiz)
    create_list(:question, 4, quiz: quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz, score: 3, completed_at: Time.current)

    assert_equal 75, quiz_attempt.score_percentage
  end

  test "score_percentage returns 0 when total questions is zero" do
    quiz = create(:quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz, score: 0)

    assert_equal 0, quiz_attempt.score_percentage
  end

  test "score_percentage returns 0 when score is nil" do
    quiz = create(:quiz)
    create_list(:question, 4, quiz: quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz, score: nil)

    assert_equal 0, quiz_attempt.score_percentage
  end

  test "score_percentage rounds to nearest integer" do
    quiz = create(:quiz)
    create_list(:question, 3, quiz: quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz, score: 1, completed_at: Time.current)

    # 1/3 = 33.33...%
    assert_equal 33, quiz_attempt.score_percentage
  end

  test "score_percentage handles perfect score" do
    quiz = create(:quiz)
    create_list(:question, 5, quiz: quiz)
    quiz_attempt = create(:quiz_attempt, quiz: quiz, score: 5, completed_at: Time.current)

    assert_equal 100, quiz_attempt.score_percentage
  end
end
