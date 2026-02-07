require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home page is accessible without authentication" do
    get root_path
    assert_response :success
  end

  test "home page displays platform stats" do
    create_list(:user, 3)
    quiz = create(:quiz, :with_questions)
    user = create(:user)
    create(:quiz_attempt, :completed, user: user, quiz: quiz)

    get root_path
    assert_response :success
    assert_select "section" # Stats section exists
  end

  test "home page displays sample question when questions exist" do
    quiz = create(:quiz, :with_questions, question_count: 1)

    get root_path
    assert_response :success
    assert_select "[data-controller='sample-quiz']"
  end

  test "home page handles no questions gracefully" do
    # Delete all related records in proper order
    UserAnswer.delete_all
    QuizAttempt.delete_all
    Answer.delete_all
    Question.delete_all

    get root_path
    assert_response :success
  end

  test "authenticated users see dashboard link" do
    user = create(:user)
    sign_in_as(user)

    get root_path
    assert_response :success
    assert_select "a[href='#{dashboard_path}']"
  end

  test "unauthenticated users see sign up link" do
    get root_path
    assert_response :success
    assert_select "a[href='#{new_registration_path}']"
  end

  test "displays tech stack badges" do
    get root_path
    assert_response :success
    assert_select "span", text: /Ruby on Rails/
    assert_select "span", text: /Tailwind CSS/
  end

  test "displays topic badges" do
    get root_path
    assert_response :success
    # Check that topics from Question::TOPICS are displayed
    assert_select "span", text: /intervals/i
    assert_select "span", text: /chords/i
  end
end
