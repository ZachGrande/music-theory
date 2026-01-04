require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  # Validations
  test "valid question" do
    question = build(:question)
    assert question.valid?
  end

  test "requires content" do
    question = build(:question, content: nil)
    assert_not question.valid?
    assert_includes question.errors[:content], "can't be blank"
  end

  test "requires difficulty" do
    question = build(:question, difficulty: nil)
    assert_not question.valid?
    assert_includes question.errors[:difficulty], "can't be blank"
  end

  test "requires topic" do
    question = build(:question, topic: nil)
    assert_not question.valid?
    assert_includes question.errors[:topic], "can't be blank"
  end

  test "requires quiz association" do
    question = build(:question, quiz: nil)
    assert_not question.valid?
  end

  # Enum
  test "difficulty enum has correct values" do
    assert_equal({ "easy" => 0, "medium" => 1, "hard" => 2 }, Question.difficulties)
  end

  test "can set difficulty levels" do
    question_easy = create(:question, :easy)
    question_medium = create(:question, difficulty: :medium)
    question_hard = create(:question, :hard)

    assert question_easy.easy?
    assert question_medium.medium?
    assert question_hard.hard?
  end

  # Topics constant
  test "TOPICS contains expected music theory topics" do
    expected_topics = %w[intervals chords scales key_signatures notes rhythm]
    assert_equal expected_topics, Question::TOPICS
  end

  # Associations
  test "belongs to quiz" do
    quiz = create(:quiz)
    question = create(:question, quiz: quiz)
    assert_equal quiz, question.quiz
  end

  test "has many answers" do
    question = create(:question)
    create_list(:answer, 4, question: question)
    assert_equal 4, question.answers.count
  end

  test "has many user answers" do
    question = create(:question, :with_answers)
    quiz_attempt = create(:quiz_attempt, quiz: question.quiz)
    create(:user_answer, question: question, quiz_attempt: quiz_attempt, answer: question.answers.first)
    assert_equal 1, question.user_answers.count
  end

  test "destroys answers when question is destroyed" do
    question = create(:question)
    create_list(:answer, 3, question: question)
    assert_difference "Answer.count", -3 do
      question.destroy
    end
  end

  test "destroys user answers when question is destroyed" do
    question = create(:question, :with_answers)
    quiz_attempt = create(:quiz_attempt, quiz: question.quiz)
    create(:user_answer, question: question, quiz_attempt: quiz_attempt, answer: question.answers.first)
    assert_difference "UserAnswer.count", -1 do
      question.destroy
    end
  end

  # Instance methods
  test "correct_answer returns the correct answer" do
    question = create(:question)
    create(:answer, question: question, correct: false)
    correct = create(:answer, question: question, correct: true)

    assert_equal correct, question.correct_answer
  end

  test "correct_answer returns nil when no correct answer exists" do
    question = create(:question)
    create(:answer, question: question, correct: false)

    assert_nil question.correct_answer
  end

  # Topic traits
  test "intervals trait sets correct topic" do
    question = create(:question, :intervals)
    assert_equal "intervals", question.topic
  end

  test "chords trait sets correct topic" do
    question = create(:question, :chords)
    assert_equal "chords", question.topic
  end
end
