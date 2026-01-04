# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    include Pagy::Method

    def index
      @pagy, @users = pagy(:offset, User.ordered)
    end

    def show
      @user = User.find(params[:id])
      @pagy, @quiz_attempts = pagy(
        :offset,
        @user.quiz_attempts.includes(:quiz).recent,
        limit: 10
      )
    end
  end
end
