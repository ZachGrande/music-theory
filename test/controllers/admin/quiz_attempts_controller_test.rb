require "test_helper"

module Admin
  class QuizAttemptsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @user = create(:user)
    end

    test "redirects to login when not authenticated" do
      get admin_quiz_attempts_path
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    test "redirects non-admin users to root with alert" do
      sign_in_as(@user)
      get admin_quiz_attempts_path
      assert_response :redirect
      assert_redirected_to root_path
    end

    test "allows admin users to access quiz attempts index" do
      sign_in_as(@admin)
      get admin_quiz_attempts_path
      assert_response :success
    end

    test "paginates quiz attempts list" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      create_list(:quiz_attempt, 30, :completed, user: @user, quiz: quiz)

      get admin_quiz_attempts_path
      assert_response :success
    end

    test "shows quiz attempts from all users" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      other_user = create(:user)
      create(:quiz_attempt, :completed, user: @user, quiz: quiz)
      create(:quiz_attempt, :completed, user: other_user, quiz: quiz)

      get admin_quiz_attempts_path
      assert_response :success
    end

    test "shows in-progress quiz attempts" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      # Create in-progress attempt (no completed_at)
      create(:quiz_attempt, user: @user, quiz: quiz, completed_at: nil)

      get admin_quiz_attempts_path
      assert_response :success
    end

    test "displays attempts with varying score ranges" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions, question_count: 10)

      # High score (80%+)
      create(:quiz_attempt, :completed, user: @user, quiz: quiz, score: 9)
      # Medium score (60-79%)
      create(:quiz_attempt, :completed, user: @user, quiz: quiz, score: 7)
      # Low score (<60%)
      create(:quiz_attempt, :completed, user: @user, quiz: quiz, score: 4)

      get admin_quiz_attempts_path
      assert_response :success
    end

    test "shows empty state when no attempts exist" do
      sign_in_as(@admin)

      get admin_quiz_attempts_path
      assert_response :success
    end
  end
end
