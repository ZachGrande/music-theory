require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
    @quiz = create(:quiz, :with_questions)
  end

  # Authentication
  test "redirects to login when not authenticated for index" do
    get quizzes_path
    assert_response :redirect
  end

  test "redirects to login when not authenticated for show" do
    get quiz_path(@quiz)
    assert_response :redirect
  end

  # Index action
  test "index returns all quizzes" do
    sign_in_as(@user)
    create_list(:quiz, 3)

    get quizzes_path
    assert_response :success
  end

  test "index filters by difficulty" do
    sign_in_as(@user)
    create(:quiz, :easy)
    create(:quiz, :hard)

    get quizzes_path(difficulty: "easy")
    assert_response :success
  end

  test "index filters by category" do
    sign_in_as(@user)
    create(:quiz, category: "theory")
    create(:quiz, category: "ear_training")

    get quizzes_path(category: "theory")
    assert_response :success
  end

  test "index filters by both difficulty and category" do
    sign_in_as(@user)
    create(:quiz, :easy, category: "theory")
    create(:quiz, :hard, category: "theory")
    create(:quiz, :easy, category: "ear_training")

    get quizzes_path(difficulty: "easy", category: "theory")
    assert_response :success
  end

  test "index handles empty results" do
    sign_in_as(@user)
    Quiz.destroy_all

    get quizzes_path
    assert_response :success
  end

  # Show action
  test "show displays quiz with questions and answers" do
    sign_in_as(@user)

    get quiz_path(@quiz)
    assert_response :success
  end

  test "show raises error for non-existent quiz" do
    sign_in_as(@user)

    get quiz_path(id: 99999)
    assert_response :not_found
  end

  test "show includes all question answers" do
    sign_in_as(@user)
    quiz = create(:quiz)
    question = create(:question, quiz: quiz)
    create_list(:answer, 4, question: question)

    get quiz_path(quiz)
    assert_response :success
  end

  test "show handles quiz with no questions" do
    sign_in_as(@user)
    empty_quiz = create(:quiz)

    get quiz_path(empty_quiz)
    assert_response :success
  end
end
