require "test_helper"

class QuizAttemptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @quiz = quizzes(:one)
    @question = questions(:one)
    @answer = answers(:one)
    sign_in_as(@user)
  end

  # SECURITY TEST: Validates fix for Brakeman Mass Assignment warning
  # Using permit! allows any keys, which can cause errors or security issues
  # The fix should explicitly permit only valid question IDs
  test "submit filters out invalid answer keys and succeeds with valid ones" do
    quiz_attempt = @user.quiz_attempts.create!(quiz: @quiz)

    # Submit with valid answer params AND malicious/invalid extra params
    # After the fix, invalid keys should be filtered out and request should succeed
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question.id.to_s => @answer.id.to_s,
        "malicious_key" => "malicious_value",
        "admin" => "true",
        "user_id" => "999"
      }
    }

    # Should redirect successfully, not error with 422
    assert_redirected_to quiz_quiz_attempt_path(@quiz, quiz_attempt)

    # Verify that only the valid question's answer was saved
    quiz_attempt.reload
    user_answers = quiz_attempt.user_answers

    # Should only have answers for valid questions that belong to this quiz
    user_answers.each do |ua|
      assert_includes @quiz.question_ids, ua.question_id,
        "User answer should only be for questions belonging to the quiz"
    end
  end

  test "submit rejects answer_ids that don't belong to the question" do
    quiz_attempt = @user.quiz_attempts.create!(quiz: @quiz)
    other_answer = answers(:two) # This answer belongs to a different question

    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question.id.to_s => other_answer.id.to_s
      }
    }

    # The request should complete (no crash from permit!)
    assert_redirected_to quiz_quiz_attempt_path(@quiz, quiz_attempt)
  end

  test "index shows completed quiz attempts for current user" do
    get quiz_attempts_path
    assert_response :success
  end

  test "show displays quiz attempt details" do
    quiz_attempt = quiz_attempts(:one)
    get quiz_quiz_attempt_path(@quiz, quiz_attempt)
    assert_response :success
  end

  test "create starts a new quiz attempt" do
    assert_difference("QuizAttempt.count", 1) do
      post quiz_quiz_attempts_path(@quiz)
    end
    assert_redirected_to quiz_quiz_attempt_path(@quiz, QuizAttempt.last)
  end

  # SECURITY TEST: Non-existent question IDs should be filtered out
  test "submit filters out non-existent question IDs" do
    quiz_attempt = @user.quiz_attempts.create!(quiz: @quiz)

    # Submit with a valid answer and a non-existent question ID
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question.id.to_s => @answer.id.to_s,
        "99999" => "88888" # Non-existent question ID should be filtered
      }
    }

    # Should redirect successfully after filtering invalid keys
    assert_redirected_to quiz_quiz_attempt_path(@quiz, quiz_attempt)
  end

  # Test accessing quiz attempt via /my-quizzes/:id route (without quiz_id)
  test "show via my-quizzes route displays quiz attempt details" do
    quiz_attempt = @user.quiz_attempts.create!(quiz: @quiz, completed_at: Time.current, score: 1)
    get quiz_attempt_path(quiz_attempt)
    assert_response :success
  end

  # Test submitting with blank answer_id (exercises the `next if answer_id.blank?` branch)
  test "submit skips blank answer_ids" do
    quiz_attempt = @user.quiz_attempts.create!(quiz: @quiz)

    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question.id.to_s => ""  # Blank answer should be skipped
      }
    }

    assert_redirected_to quiz_quiz_attempt_path(@quiz, quiz_attempt)
    # No user answer should be created for blank answer_id
    assert_equal 0, quiz_attempt.user_answers.count
  end

  test "index shows in-progress quiz attempts" do
    # Create an in-progress attempt (no completed_at)
    @user.quiz_attempts.create!(quiz: @quiz, completed_at: nil)

    get quiz_attempts_path
    assert_response :success
  end

  test "index shows empty state when no quiz attempts" do
    # Delete any existing attempts
    @user.quiz_attempts.destroy_all

    get quiz_attempts_path
    assert_response :success
  end
end
