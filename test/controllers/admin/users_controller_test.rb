require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @user = create(:user)
    end

    test "redirects to login when not authenticated" do
      get admin_users_path
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    test "redirects non-admin users to root with alert" do
      sign_in_as(@user)
      get admin_users_path
      assert_response :redirect
      assert_redirected_to root_path
    end

    test "allows admin users to access users index" do
      sign_in_as(@admin)
      get admin_users_path
      assert_response :success
    end

    test "paginates users list" do
      sign_in_as(@admin)
      create_list(:user, 30)

      get admin_users_path
      assert_response :success
    end

    test "allows admin to view user details" do
      sign_in_as(@admin)
      get admin_user_path(@user)
      assert_response :success
    end

    test "shows user quiz history on user detail page" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      create_list(:quiz_attempt, 5, :completed, user: @user, quiz: quiz)

      get admin_user_path(@user)
      assert_response :success
    end

    test "non-admin cannot view user details" do
      sign_in_as(@user)
      other_user = create(:user)
      get admin_user_path(other_user)
      assert_response :redirect
      assert_redirected_to root_path
    end

    test "shows user with no completed quizzes" do
      sign_in_as(@admin)
      # User has no quiz attempts at all
      get admin_user_path(@user)
      assert_response :success
      assert_select "div", text: /This user has not attempted any quizzes yet/
    end

    test "shows user with in-progress quiz attempt" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      # Create in-progress attempt (no completed_at)
      create(:quiz_attempt, user: @user, quiz: quiz, completed_at: nil)

      get admin_user_path(@user)
      assert_response :success
    end

    test "shows user with zero streak" do
      sign_in_as(@admin)
      @user.update!(current_streak: 0, longest_streak: 0)

      get admin_user_path(@user)
      assert_response :success
    end

    test "shows user with active streak" do
      sign_in_as(@admin)
      @user.update!(current_streak: 5, longest_streak: 10)

      get admin_user_path(@user)
      assert_response :success
    end

    test "shows admin badge for admin users" do
      sign_in_as(@admin)
      get admin_users_path
      assert_response :success
      assert_select "span", text: /Admin/
    end

    test "shows admin badge on user detail page for admin user" do
      sign_in_as(@admin)
      other_admin = create(:user, :admin)

      get admin_user_path(other_admin)
      assert_response :success
      assert_match /Admin/, response.body
      assert_match /bg-purple-100/, response.body
    end

    test "displays users with varying score ranges" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions, question_count: 10)

      # High score user (80%+)
      high_user = create(:user)
      create(:quiz_attempt, :completed, user: high_user, quiz: quiz, score: 9)

      # Medium score user (60-79%)
      medium_user = create(:user)
      create(:quiz_attempt, :completed, user: medium_user, quiz: quiz, score: 7)

      # Low score user (<60%)
      low_user = create(:user)
      create(:quiz_attempt, :completed, user: low_user, quiz: quiz, score: 4)

      get admin_users_path
      assert_response :success
    end

    test "displays user with 1 day streak (singular)" do
      sign_in_as(@admin)
      @user.update!(current_streak: 1)

      get admin_users_path
      assert_response :success
      assert_match /🔥 1 day[^s]/, response.body
    end

    test "displays user with multiple day streak (plural)" do
      sign_in_as(@admin)
      @user.update!(current_streak: 5)

      get admin_users_path
      assert_response :success
      assert_match /🔥 5 days/, response.body
    end
  end
end
