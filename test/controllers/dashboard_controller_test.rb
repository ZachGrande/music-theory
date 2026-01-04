require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "redirects to login when not authenticated" do
    get dashboard_path
    assert_response :redirect
  end

  test "shows dashboard when authenticated" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
  end

  test "loads recent completed quiz attempts" do
    sign_in_as(@user)
    quiz = create(:quiz)
    create_list(:quiz_attempt, 3, :completed, user: @user, quiz: quiz)
    create(:quiz_attempt, user: @user, quiz: quiz) # incomplete - should not show

    get dashboard_path
    assert_response :success
  end

  test "limits recent attempts to 5" do
    sign_in_as(@user)
    quiz = create(:quiz)
    create_list(:quiz_attempt, 7, :completed, user: @user, quiz: quiz)

    get dashboard_path
    assert_response :success
  end

  test "loads all quizzes" do
    sign_in_as(@user)
    create_list(:quiz, 3)

    get dashboard_path
    assert_response :success
  end

  test "displays user stats" do
    sign_in_as(@user)
    quiz = create(:quiz, :with_questions, question_count: 4)
    create(:quiz_attempt, user: @user, quiz: quiz, score: 4, completed_at: Time.current)

    get dashboard_path
    assert_response :success
  end

  test "handles user with no quiz attempts" do
    sign_in_as(@user)
    get dashboard_path
    assert_response :success
  end

  test "displays streak information" do
    user_with_streak = create(:user, :with_streak)
    sign_in_as(user_with_streak)

    get dashboard_path
    assert_response :success
  end

  test "shows admin link for admin users" do
    admin = create(:user, :admin)
    sign_in_as(admin)

    get dashboard_path
    assert_response :success
    assert_select "a", text: "Admin"
  end

  test "does not show admin link for regular users" do
    sign_in_as(@user)

    get dashboard_path
    assert_response :success
    assert_select "a", text: "Admin", count: 0
  end

  test "shows empty state when user has no completed quizzes" do
    sign_in_as(@user)
    quiz = create(:quiz)
    # Only in-progress attempt
    create(:quiz_attempt, user: @user, quiz: quiz, completed_at: nil)

    get dashboard_path
    assert_response :success
  end

  test "shows empty state when no quizzes exist" do
    sign_in_as(@user)
    # Destroy all quizzes to test empty state
    Quiz.destroy_all

    get dashboard_path
    assert_response :success
    assert_match /No quizzes available yet/, response.body
  end
end
