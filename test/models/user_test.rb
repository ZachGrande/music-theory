require "test_helper"

class UserTest < ActiveSupport::TestCase
  # Validations
  test "valid user" do
    user = build(:user)
    assert user.valid?
  end

  test "requires password" do
    user = build(:user, password: nil, password_confirmation: nil)
    assert_not user.valid?
  end

  test "requires password confirmation to match" do
    user = build(:user, password: "password123", password_confirmation: "different")
    assert_not user.valid?
  end

  # Email normalization
  test "normalizes email address to lowercase" do
    user = create(:user, email_address: "TEST@EXAMPLE.COM")
    assert_equal "test@example.com", user.email_address
  end

  test "strips whitespace from email address" do
    user = create(:user, email_address: "  test@example.com  ")
    assert_equal "test@example.com", user.email_address
  end

  # Associations
  test "has many sessions" do
    user = create(:user)
    create_list(:session, 2, user: user)
    assert_equal 2, user.sessions.count
  end

  test "has many quiz attempts" do
    user = create(:user)
    quiz = create(:quiz)
    create_list(:quiz_attempt, 3, user: user, quiz: quiz)
    assert_equal 3, user.quiz_attempts.count
  end

  test "destroys sessions when user is destroyed" do
    user = create(:user)
    create(:session, user: user)
    assert_difference "Session.count", -1 do
      user.destroy
    end
  end

  test "destroys quiz attempts when user is destroyed" do
    user = create(:user)
    quiz = create(:quiz)
    create(:quiz_attempt, user: user, quiz: quiz)
    assert_difference "QuizAttempt.count", -1 do
      user.destroy
    end
  end

  # Instance methods
  test "completed_quizzes_count returns count of completed attempts" do
    user = create(:user)
    quiz = create(:quiz)
    create(:quiz_attempt, :completed, user: user, quiz: quiz)
    create(:quiz_attempt, :completed, user: user, quiz: quiz)
    create(:quiz_attempt, user: user, quiz: quiz) # incomplete

    assert_equal 2, user.completed_quizzes_count
  end

  test "completed_quizzes_count returns 0 when no completed attempts" do
    user = create(:user)
    quiz = create(:quiz)
    create(:quiz_attempt, user: user, quiz: quiz) # incomplete

    assert_equal 0, user.completed_quizzes_count
  end

  test "average_score returns 0 when no completed attempts" do
    user = create(:user)
    assert_equal 0, user.average_score
  end

  test "average_score calculates average percentage of completed attempts" do
    user = create(:user)
    quiz = create(:quiz, :with_questions, question_count: 4)

    # Create two attempts with different scores
    create(:quiz_attempt, user: user, quiz: quiz, score: 4, completed_at: Time.current)
    create(:quiz_attempt, user: user, quiz: quiz, score: 2, completed_at: Time.current)

    # 4/4 = 100%, 2/4 = 50%, average = 75%
    assert_equal 75, user.average_score
  end

  test "average_score ignores incomplete attempts" do
    user = create(:user)
    quiz = create(:quiz, :with_questions, question_count: 4)

    create(:quiz_attempt, user: user, quiz: quiz, score: 4, completed_at: Time.current)
    create(:quiz_attempt, user: user, quiz: quiz, score: nil, completed_at: nil) # incomplete

    assert_equal 100, user.average_score
  end

  # Authentication
  test "authenticates with correct password" do
    user = create(:user, password: "secret123", password_confirmation: "secret123")
    assert user.authenticate("secret123")
  end

  test "does not authenticate with incorrect password" do
    user = create(:user, password: "secret123", password_confirmation: "secret123")
    assert_not user.authenticate("wrongpassword")
  end
end
