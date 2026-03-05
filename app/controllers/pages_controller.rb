# frozen_string_literal: true

class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @stats = PlatformStats.calculate
    @sample_question = Question.includes(:answers).order("RANDOM()").first
  end
end
