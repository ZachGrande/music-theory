require "test_helper"

class QuizFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @quiz = create(:quiz, title: "Basic Music Theory")

    # Create questions with answers
    @question1 = create(:question, quiz: @quiz, content: "What note is the 5th of C?")
    @correct_answer1 = create(:answer, question: @question1, content: "G", correct: true)
    @wrong_answer1 = create(:answer, question: @question1, content: "F", correct: false)

    @question2 = create(:question, quiz: @quiz, content: "What is a major 3rd above C?")
    @correct_answer2 = create(:answer, question: @question2, content: "E", correct: true)
    @wrong_answer2 = create(:answer, question: @question2, content: "D", correct: false)

    @question3 = create(:question, quiz: @quiz, content: "How many notes in a major scale?")
    @correct_answer3 = create(:answer, question: @question3, content: "7", correct: true)
    @wrong_answer3 = create(:answer, question: @question3, content: "8", correct: false)
  end

  test "complete quiz flow with all correct answers" do
    sign_in_as(@user)

    # View quiz list
    get quizzes_path
    assert_response :success

    # View quiz details
    get quiz_path(@quiz)
    assert_response :success

    # Start quiz attempt
    post quiz_quiz_attempts_path(@quiz)
    assert_response :redirect
    quiz_attempt = @user.quiz_attempts.last
    follow_redirect!
    assert_response :success

    # Submit answers (all correct) - uses POST not PATCH
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question1.id.to_s => @correct_answer1.id.to_s,
        @question2.id.to_s => @correct_answer2.id.to_s,
        @question3.id.to_s => @correct_answer3.id.to_s
      }
    }
    assert_response :redirect

    # Verify quiz was graded
    quiz_attempt.reload
    assert_equal 3, quiz_attempt.score
    assert quiz_attempt.completed?
    assert_equal 100, quiz_attempt.score_percentage

    # Verify streak was updated
    @user.reload
    assert_equal 1, @user.current_streak
    assert_equal Date.current, @user.last_quiz_date
  end

  test "complete quiz flow with some incorrect answers" do
    sign_in_as(@user)

    # Start quiz attempt
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last
    follow_redirect!

    # Submit answers (1 correct, 2 wrong) - uses POST
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question1.id.to_s => @correct_answer1.id.to_s,
        @question2.id.to_s => @wrong_answer2.id.to_s,
        @question3.id.to_s => @wrong_answer3.id.to_s
      }
    }

    quiz_attempt.reload
    assert_equal 1, quiz_attempt.score
    assert_equal 33, quiz_attempt.score_percentage
  end

  test "quiz attempt appears in user history" do
    sign_in_as(@user)

    # Complete a quiz
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question1.id.to_s => @correct_answer1.id.to_s,
        @question2.id.to_s => @correct_answer2.id.to_s,
        @question3.id.to_s => @correct_answer3.id.to_s
      }
    }

    # View quiz attempts history
    get quiz_attempts_path
    assert_response :success
  end

  test "dashboard shows completed quiz stats" do
    sign_in_as(@user)

    # Complete a quiz
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question1.id.to_s => @correct_answer1.id.to_s,
        @question2.id.to_s => @correct_answer2.id.to_s,
        @question3.id.to_s => @correct_answer3.id.to_s
      }
    }

    # Check dashboard
    get dashboard_path
    assert_response :success

    # Verify stats are updated
    @user.reload
    assert_equal 1, @user.completed_quizzes_count
    assert_equal 100, @user.average_score
  end

  test "multiple quizzes on consecutive days builds streak" do
    sign_in_as(@user)

    # Set up as if user took a quiz yesterday
    @user.update!(last_quiz_date: Date.current - 1.day, current_streak: 1, longest_streak: 1)

    # Complete a quiz today
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: { @question1.id.to_s => @correct_answer1.id.to_s }
    }

    @user.reload
    assert_equal 2, @user.current_streak
  end

  test "viewing quiz attempt results shows answers" do
    sign_in_as(@user)

    # Complete a quiz
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last
    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: {
        @question1.id.to_s => @correct_answer1.id.to_s,
        @question2.id.to_s => @wrong_answer2.id.to_s,
        @question3.id.to_s => @correct_answer3.id.to_s
      }
    }

    # View results
    get quiz_quiz_attempt_path(@quiz, quiz_attempt)
    assert_response :success
  end

  test "unauthenticated user cannot start quiz" do
    post quiz_quiz_attempts_path(@quiz)
    assert_response :redirect
  end

  test "unauthenticated user cannot submit quiz" do
    # First sign in to create the attempt
    sign_in_as(@user)
    post quiz_quiz_attempts_path(@quiz)
    quiz_attempt = @user.quiz_attempts.last

    # Sign out and try to submit
    sign_out

    post submit_quiz_quiz_attempt_path(@quiz, quiz_attempt), params: {
      answers: { @question1.id.to_s => @correct_answer1.id.to_s }
    }
    assert_response :redirect
  end
end
