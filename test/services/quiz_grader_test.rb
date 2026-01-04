require "test_helper"

class QuizGraderTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @quiz = create(:quiz)
    @question1 = create(:question, quiz: @quiz)
    @question2 = create(:question, quiz: @quiz)
    @question3 = create(:question, quiz: @quiz)

    @correct_answer1 = create(:answer, :correct, question: @question1)
    @incorrect_answer1 = create(:answer, question: @question1)

    @correct_answer2 = create(:answer, :correct, question: @question2)
    @incorrect_answer2 = create(:answer, question: @question2)

    @correct_answer3 = create(:answer, :correct, question: @question3)
    @incorrect_answer3 = create(:answer, question: @question3)

    @quiz_attempt = create(:quiz_attempt, user: @user, quiz: @quiz)
  end

  test "grades quiz with all correct answers" do
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question1, answer: @correct_answer1)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question2, answer: @correct_answer2)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question3, answer: @correct_answer3)

    grader = QuizGrader.new(@quiz_attempt)
    score = grader.grade!

    assert_equal 3, score
    assert_equal 3, @quiz_attempt.reload.score
    assert_not_nil @quiz_attempt.completed_at
  end

  test "grades quiz with all incorrect answers" do
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question1, answer: @incorrect_answer1)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question2, answer: @incorrect_answer2)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question3, answer: @incorrect_answer3)

    grader = QuizGrader.new(@quiz_attempt)
    score = grader.grade!

    assert_equal 0, score
    assert_equal 0, @quiz_attempt.reload.score
    assert_not_nil @quiz_attempt.completed_at
  end

  test "grades quiz with mixed answers" do
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question1, answer: @correct_answer1)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question2, answer: @incorrect_answer2)
    create(:user_answer, quiz_attempt: @quiz_attempt, question: @question3, answer: @correct_answer3)

    grader = QuizGrader.new(@quiz_attempt)
    score = grader.grade!

    assert_equal 2, score
    assert_equal 2, @quiz_attempt.reload.score
  end

  test "sets completed_at timestamp" do
    grader = QuizGrader.new(@quiz_attempt)

    freeze_time do
      grader.grade!
      assert_equal Time.current, @quiz_attempt.reload.completed_at
    end
  end

  test "updates user streak after grading" do
    assert_nil @user.last_quiz_date

    grader = QuizGrader.new(@quiz_attempt)
    grader.grade!

    @user.reload
    assert_equal Date.current, @user.last_quiz_date
    assert_equal 1, @user.current_streak
  end

  test "grades quiz with no user answers" do
    grader = QuizGrader.new(@quiz_attempt)
    score = grader.grade!

    assert_equal 0, score
    assert_equal 0, @quiz_attempt.reload.score
    assert_not_nil @quiz_attempt.completed_at
  end
end
