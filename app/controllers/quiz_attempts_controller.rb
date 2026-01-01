class QuizAttemptsController < ApplicationController
  before_action :set_quiz, only: %i[create show submit], if: -> { params[:quiz_id].present? }
  before_action :set_quiz_attempt, only: %i[show submit]

  def index
    @quiz_attempts = Current.user.quiz_attempts.completed.recent.includes(:quiz)
  end

  def show
    @questions = @quiz_attempt.quiz.questions.includes(:answers)
    @user_answers = @quiz_attempt.user_answers.index_by(&:question_id)
  end

  def create
    @quiz_attempt = Current.user.quiz_attempts.create!(quiz: @quiz)
    redirect_to quiz_quiz_attempt_path(@quiz, @quiz_attempt)
  end

  def submit
    save_answers
    QuizGrader.new(@quiz_attempt).grade!
    redirect_to quiz_quiz_attempt_path(@quiz, @quiz_attempt), notice: "Quiz completed! You scored #{@quiz_attempt.score}/#{@quiz_attempt.total_questions}"
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def set_quiz_attempt
    @quiz_attempt = if params[:quiz_id].present?
      @quiz.quiz_attempts.find(params[:id])
    else
      Current.user.quiz_attempts.find(params[:id])
    end
  end

  def save_answers
    answers_params.each do |question_id, answer_id|
      next if answer_id.blank?

      @quiz_attempt.user_answers.find_or_initialize_by(question_id: question_id).tap do |ua|
        ua.answer_id = answer_id
        ua.save!
      end
    end
  end

  def answers_params
    # Only permit question IDs that belong to this quiz's questions
    valid_question_ids = @quiz.question_ids.map(&:to_s)
    params.fetch(:answers, {}).permit(*valid_question_ids).to_h
  end
end
