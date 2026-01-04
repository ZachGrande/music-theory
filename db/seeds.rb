# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require "yaml"

# Capture base time once - all timestamps are relative to this
# This allows the database to be reset multiple times with consistent relative dates
BASE_TIME = Time.current
BASE_DATE = BASE_TIME.to_date

puts "Seeding music theory quizzes..."
puts "Base time: #{BASE_TIME}"

# Load quiz data from YAML
quiz_data = YAML.load_file(Rails.root.join("db", "seeds", "quizzes.yml"))

quiz_data["quizzes"].each do |quiz_attrs|
  quiz = Quiz.find_or_create_by!(title: quiz_attrs["title"]) do |q|
    q.description = quiz_attrs["description"]
    q.category = quiz_attrs["category"]
    q.difficulty = quiz_attrs["difficulty"].to_sym
  end

  quiz_attrs["questions"].each do |question_attrs|
    question = quiz.questions.find_or_create_by!(content: question_attrs["content"]) do |q|
      q.topic = question_attrs["topic"]
      q.difficulty = question_attrs["difficulty"].to_sym
    end

    question_attrs["answers"].each do |answer_attrs|
      question.answers.find_or_create_by!(content: answer_attrs["content"]) do |a|
        a.correct = answer_attrs["correct"]
      end
    end
  end
end

puts "Created #{Quiz.count} quizzes with #{Question.count} questions and #{Answer.count} answers."

# --- Seed Users and Quiz Attempts ---

puts "\nSeeding users and quiz attempts..."

user_data = YAML.load_file(Rails.root.join("db", "seeds", "users.yml"))
all_quizzes = Quiz.includes(questions: :answers).all.to_a

# Helper method to select an answer based on accuracy
def select_answer_for_question(question, accuracy)
  correct_answer = question.answers.find(&:correct?)
  incorrect_answers = question.answers.reject(&:correct?)

  if rand < accuracy
    correct_answer
  else
    incorrect_answers.sample || correct_answer
  end
end

# Helper method to create a quiz attempt with user answers
def create_quiz_attempt(user:, quiz:, accuracy:, completed_at:)
  # Create the attempt
  attempt = QuizAttempt.new(
    user: user,
    quiz: quiz,
    created_at: completed_at - rand(5..30).minutes,
    updated_at: completed_at
  )
  attempt.save!(validate: false)

  # Create user answers for each question
  score = 0
  quiz.questions.each do |question|
    selected_answer = select_answer_for_question(question, accuracy)
    score += 1 if selected_answer.correct?

    user_answer = UserAnswer.new(
      quiz_attempt: attempt,
      question: question,
      answer: selected_answer,
      created_at: completed_at - rand(1..4).minutes,
      updated_at: completed_at
    )
    user_answer.save!(validate: false)
  end

  # Update the attempt with score and completion time
  attempt.update_columns(score: score, completed_at: completed_at)
  attempt
end

# Helper method to calculate streak info from history
def calculate_streak_info(streak_history)
  return { current_streak: 0, longest_streak: 0, last_quiz_date: nil } if streak_history.empty?

  sorted_days = streak_history.map { |h| h["days_ago"] }.sort

  # Calculate current streak (consecutive days ending at the most recent day)
  most_recent_day = sorted_days.first
  current_streak = 0

  if most_recent_day <= 1 # Only count current streak if played today or yesterday
    current_streak = 1
    sorted_days.each_cons(2) do |newer, older|
      if older - newer == 1
        current_streak += 1
      else
        break
      end
    end
  end

  # Calculate longest streak by finding the longest consecutive sequence
  longest_streak = 1
  current_run = 1

  sorted_days.each_cons(2) do |newer, older|
    if older - newer == 1
      current_run += 1
      longest_streak = [ longest_streak, current_run ].max
    else
      current_run = 1
    end
  end

  # For power users, use their configured longest streak if higher
  last_quiz_date = BASE_DATE - sorted_days.first.days

  {
    current_streak: current_streak,
    longest_streak: longest_streak,
    last_quiz_date: last_quiz_date
  }
end

user_data["users"].each do |user_attrs|
  profile = user_attrs["profile"]
  streak_history = profile["streak_history"] || []
  accuracy = profile["accuracy"]

  # Find or create user
  user = User.find_or_initialize_by(email_address: user_attrs["email"])

  if user.new_record?
    user.password = user_attrs["password"]
    user.password_confirmation = user_attrs["password"]
    user.save!
    puts "  Created user: #{user.email_address} (#{profile['type']})"
  else
    puts "  Found existing user: #{user.email_address}"
  end

  # Skip if user already has quiz attempts (idempotent)
  if user.quiz_attempts.any?
    puts "    Skipping quiz attempts - user already has #{user.quiz_attempts.count} attempts"
    next
  end

  # Create quiz attempts based on streak history
  quiz_index = 0
  streak_history.each do |day_info|
    days_ago = day_info["days_ago"]
    attempts_count = day_info["attempts"] || 1

    attempts_count.times do |i|
      quiz = all_quizzes[quiz_index % all_quizzes.length]
      quiz_index += 1

      # Set completion time: base_time minus days, with some hour variation
      hour_offset = rand(8..22) # Between 8am and 10pm
      minute_offset = rand(0..59)
      completed_at = (BASE_DATE - days_ago.days).to_time + hour_offset.hours + minute_offset.minutes

      attempt = create_quiz_attempt(
        user: user,
        quiz: quiz,
        accuracy: accuracy,
        completed_at: completed_at
      )

      puts "    Created attempt: #{quiz.title} (#{attempt.score}/#{quiz.questions.count}) - #{days_ago} days ago"
    end
  end

  # Calculate and set streak info based on history
  streak_info = calculate_streak_info(streak_history)

  # For power_user_lapsed, override longest_streak from profile
  if profile["type"] == "power_user_lapsed" && profile["longest_streak"]
    streak_info[:longest_streak] = profile["longest_streak"]
  end

  user.update_columns(
    current_streak: streak_info[:current_streak],
    longest_streak: streak_info[:longest_streak],
    last_quiz_date: streak_info[:last_quiz_date]
  )

  puts "    Streak: #{streak_info[:current_streak]} current, #{streak_info[:longest_streak]} longest"
end

puts "\nSeeding complete!"
puts "Created #{Quiz.count} quizzes with #{Question.count} questions and #{Answer.count} answers."
puts "Created #{User.count} users with #{QuizAttempt.count} quiz attempts."
