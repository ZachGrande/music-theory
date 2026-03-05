require "test_helper"

class PlatformStatsTest < ActiveSupport::TestCase
  test "returns stats hash with required keys" do
    stats = PlatformStats.calculate

    assert stats.key?(:total_users)
    assert stats.key?(:total_quizzes)
    assert stats.key?(:quizzes_completed)
    assert stats.key?(:questions_answered)
    assert stats.key?(:active_learners)
    assert stats.key?(:average_score)
  end

  test "counts total users including new ones" do
    initial_count = User.count
    create_list(:user, 3)

    stats = PlatformStats.new.calculate

    assert_equal initial_count + 3, stats[:total_users]
  end

  test "counts total quizzes including new ones" do
    initial_count = Quiz.count
    create_list(:quiz, 2)

    stats = PlatformStats.new.calculate

    assert_equal initial_count + 2, stats[:total_quizzes]
  end

  test "counts completed quiz attempts" do
    initial_completed = QuizAttempt.completed.count
    quiz = create(:quiz, :with_questions)
    user = create(:user)
    create_list(:quiz_attempt, 3, :completed, user: user, quiz: quiz)
    create(:quiz_attempt, user: user, quiz: quiz) # incomplete

    stats = PlatformStats.new.calculate

    assert_equal initial_completed + 3, stats[:quizzes_completed]
  end

  test "counts questions answered" do
    initial_answers = UserAnswer.count
    quiz = create(:quiz, :with_questions, question_count: 4)
    user = create(:user)
    attempt = create(:quiz_attempt, :completed, user: user, quiz: quiz)

    quiz.questions.each do |question|
      create(:user_answer, quiz_attempt: attempt, question: question, answer: question.answers.first)
    end

    stats = PlatformStats.new.calculate

    assert_equal initial_answers + 4, stats[:questions_answered]
  end

  test "counts active learners with streaks" do
    # Reset streaks on existing users for test isolation
    User.update_all(current_streak: 0)

    create(:user, current_streak: 5)
    create(:user, current_streak: 1)
    create(:user, current_streak: 0) # no active streak

    stats = PlatformStats.new.calculate

    assert_equal 2, stats[:active_learners]
  end

  test "calculates average score from completed attempts" do
    # Clear existing attempts for accurate calculation
    UserAnswer.delete_all
    QuizAttempt.delete_all

    quiz = create(:quiz, :with_questions, question_count: 10)
    user1 = create(:user)
    user2 = create(:user)

    # Score 8/10 = 80%
    create(:quiz_attempt, :completed, user: user1, quiz: quiz, score: 8)
    # Score 6/10 = 60%
    create(:quiz_attempt, :completed, user: user2, quiz: quiz, score: 6)

    stats = PlatformStats.new.calculate

    assert_equal 70.0, stats[:average_score]
  end

  test "returns zero average score when no completed attempts" do
    UserAnswer.delete_all
    QuizAttempt.delete_all

    stats = PlatformStats.new.calculate

    assert_equal 0, stats[:average_score]
  end

  test "calculate method returns stats hash" do
    # Test the class method works
    stats = PlatformStats.calculate

    assert stats.is_a?(Hash)
    assert stats.key?(:total_users)
    assert stats.key?(:total_quizzes)
    assert stats.key?(:quizzes_completed)
    assert stats.key?(:questions_answered)
    assert stats.key?(:active_learners)
    assert stats.key?(:average_score)
  end
end
