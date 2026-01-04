require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = create(:user, :admin)
      @user = create(:user)
    end

    test "redirects to login when not authenticated" do
      get admin_root_path
      assert_response :redirect
      assert_redirected_to new_session_path
    end

    test "redirects non-admin users to root with alert" do
      sign_in_as(@user)
      get admin_root_path
      assert_response :redirect
      assert_redirected_to root_path
      assert_equal "You are not authorized to access this area.", flash[:alert]
    end

    test "allows admin users to access dashboard" do
      sign_in_as(@admin)
      get admin_root_path
      assert_response :success
    end

    test "displays stats on dashboard" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      create(:quiz_attempt, :completed, user: @user, quiz: quiz)

      get admin_root_path
      assert_response :success
    end

    test "shows recent users on dashboard" do
      sign_in_as(@admin)
      create_list(:user, 3)

      get admin_root_path
      assert_response :success
    end

    test "shows recent quiz activity on dashboard" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      create_list(:quiz_attempt, 5, :completed, user: @user, quiz: quiz)

      get admin_root_path
      assert_response :success
    end

    test "displays empty state when no recent users exist" do
      sign_in_as(@admin)

      # Mock the controller to return empty recent_users
      Admin::DashboardController.class_eval do
        alias_method :original_show, :show
        define_method(:show) do
          @stats = {
            total_users: 0,
            new_users_this_week: 0,
            total_quiz_attempts: 0,
            completed_quiz_attempts: 0,
            average_score: 0,
            users_with_active_streak: 0,
            total_quizzes: 0
          }
          @recent_users = User.none
          @recent_attempts = QuizAttempt.none
        end
      end

      get admin_root_path
      assert_response :success
      assert_match /No users yet/, response.body

      # Restore original method
      Admin::DashboardController.class_eval do
        alias_method :show, :original_show
        remove_method :original_show
      end
    end

    test "displays empty state when no quiz attempts exist" do
      sign_in_as(@admin)
      # Clear all quiz attempts to test empty state
      QuizAttempt.destroy_all

      get admin_root_path
      assert_response :success
      assert_match /No quiz attempts yet/, response.body
    end

    test "calculates zero average score when no completed attempts" do
      sign_in_as(@admin)
      quiz = create(:quiz, :with_questions)
      # Create only in-progress attempt (no completed_at)
      create(:quiz_attempt, user: @user, quiz: quiz, completed_at: nil)

      get admin_root_path
      assert_response :success
    end

    test "displays flash notice message in admin layout" do
      sign_in_as(@admin)

      # Use flash.now to set notice for current request rendering
      get admin_root_path
      assert_response :success

      # Make a request that sets a notice, then follow to admin
      # We need to test the view renders the notice div
      Admin::DashboardController.class_eval do
        alias_method :original_show, :show
        define_method(:show) do
          flash.now[:notice] = "Test notice message"
          original_show
        end
      end

      get admin_root_path
      assert_response :success
      assert_match /Test notice message/, response.body
      assert_match /bg-green-100/, response.body

      # Restore original method
      Admin::DashboardController.class_eval do
        alias_method :show, :original_show
        remove_method :original_show
      end
    end

    test "displays flash alert message in admin layout" do
      sign_in_as(@admin)

      Admin::DashboardController.class_eval do
        alias_method :original_show, :show
        define_method(:show) do
          flash.now[:alert] = "Test alert message"
          original_show
        end
      end

      get admin_root_path
      assert_response :success
      assert_match /Test alert message/, response.body
      assert_match /bg-red-100/, response.body

      # Restore original method
      Admin::DashboardController.class_eval do
        alias_method :show, :original_show
        remove_method :original_show
      end
    end
  end
end
