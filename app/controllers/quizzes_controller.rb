class QuizzesController < ApplicationController
  def index
    @quizzes = Quiz.all.includes(:questions)
    @quizzes = @quizzes.where(difficulty: params[:difficulty]) if params[:difficulty].present?
    @quizzes = @quizzes.where(category: params[:category]) if params[:category].present?
  end

  def show
    @quiz = Quiz.includes(questions: :answers).find(params[:id])
  end
end
