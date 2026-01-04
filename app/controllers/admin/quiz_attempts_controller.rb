# frozen_string_literal: true

module Admin
  class QuizAttemptsController < BaseController
    include Pagy::Method

    def index
      @pagy, @quiz_attempts = pagy(
        :offset,
        QuizAttempt.includes(:user, :quiz).recent
      )
    end
  end
end
