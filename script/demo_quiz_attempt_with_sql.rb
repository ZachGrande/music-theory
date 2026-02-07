#!/usr/bin/env ruby
# frozen_string_literal: true

# Interactive Rails script that demonstrates how ActiveRecord translates to SQL queries.
#
# This educational script walks through a complete quiz attempt workflow, showing:
#   - INSERT operations when creating users, quizzes, questions, and answers
#   - SELECT queries when retrieving data
#   - INNER JOIN operations when calculating scores (joining user_answers with answers)
#   - WHERE clauses for filtering correct answers
#   - COUNT aggregations for scoring
#   - UPDATE operations for saving results
#   - Eager loading with includes() to optimize query performance
#
# The script creates temporary demo data, displays formatted SQL output with color-coded
# visualizations, and optionally cleans up after completion.
#
# Run with: rails runner script/demo_quiz_attempt_with_sql.rb

require 'io/console'

class SqlVisualizer
  COLORS = {
    reset: "\e[0m",
    bold: "\e[1m",
    green: "\e[32m",
    blue: "\e[34m",
    yellow: "\e[33m",
    cyan: "\e[36m",
    magenta: "\e[35m",
    red: "\e[31m"
  }.freeze

  def self.print_header(text)
    puts "\n#{COLORS[:bold]}#{COLORS[:cyan]}#{'=' * 80}#{COLORS[:reset]}"
    puts "#{COLORS[:bold]}#{COLORS[:cyan]}#{text.center(80)}#{COLORS[:reset]}"
    puts "#{COLORS[:bold]}#{COLORS[:cyan]}#{'=' * 80}#{COLORS[:reset]}\n"
  end

  def self.print_section(text)
    puts "\n#{COLORS[:bold]}#{COLORS[:yellow]}## #{text}#{COLORS[:reset]}\n"
  end

  def self.print_sql(sql)
    puts "#{COLORS[:blue]}#{COLORS[:bold]}SQL Query:#{COLORS[:reset]}"
    puts "#{COLORS[:cyan]}#{sql}#{COLORS[:reset]}\n\n"
  end

  def self.print_table(headers, rows)
    return if rows.empty?

    # Calculate column widths
    col_widths = headers.map.with_index do |header, i|
      max_row_width = rows.map { |row| row[i].to_s.length }.max || 0
      [ header.length, max_row_width ].max + 2
    end

    # Print top border
    puts "┌#{col_widths.map { |w| '─' * w }.join('┬')}┐"

    # Print headers
    header_row = headers.map.with_index { |h, i| " #{h.ljust(col_widths[i] - 1)}" }.join('│')
    puts "│#{COLORS[:bold]}#{COLORS[:green]}#{header_row}#{COLORS[:reset]}│"

    # Print header separator
    puts "├#{col_widths.map { |w| '─' * w }.join('┼')}┤"

    # Print rows
    rows.each do |row|
      formatted_row = row.map.with_index { |cell, i| " #{cell.to_s.ljust(col_widths[i] - 1)}" }.join('│')
      puts "│#{formatted_row}│"
    end

    # Print bottom border
    puts "└#{col_widths.map { |w| '─' * w }.join('┴')}┘\n"
  end

  def self.print_join_visualization(quiz_attempt)
    print_section("JOIN VISUALIZATION")

    puts "#{COLORS[:magenta]}This query joins multiple tables to get quiz attempt details:#{COLORS[:reset]}\n\n"

    puts "  ┌──────────────┐"
    puts "  │ quiz_attempts│"
    puts "  └──────┬───────┘"
    puts "         │ belongs_to"
    puts "         ▼"
    puts "  ┌──────────────┐         ┌──────────────┐"
    puts "  │    quizzes   │◄────────│  questions   │"
    puts "  └──────────────┘         └──────┬───────┘"
    puts "         ▲                         │"
    puts "         │                         │ has_many"
    puts "         │                         ▼"
    puts "  ┌──────┴───────┐         ┌──────────────┐"
    puts "  │ user_answers │─────────│   answers    │"
    puts "  └──────────────┘         └──────────────┘"
    puts "         │"
    puts "         │ belongs_to"
    puts "         ▼"
    puts "  ┌──────────────┐"
    puts "  │  questions   │"
    puts "  └──────────────┘\n\n"
  end

  def self.print_success(text)
    puts "#{COLORS[:green]}✓ #{text}#{COLORS[:reset]}"
  end

  def self.print_info(text)
    puts "#{COLORS[:blue]}ℹ #{text}#{COLORS[:reset]}"
  end
end

# Enable SQL logging
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::DEBUG

SqlVisualizer.print_header("QUIZ ATTEMPT SQL DEMONSTRATION")

puts "#{SqlVisualizer::COLORS[:yellow]}This script demonstrates how Rails uses SQL JOINs to retrieve quiz attempt data.#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:yellow]}Watch the SQL queries being executed!#{SqlVisualizer::COLORS[:reset]}\n"

# Clean up any existing demo data
SqlVisualizer.print_section("Step 1: Clean Up Demo Data")
User.where(email_address: 'demo@example.com').destroy_all
SqlVisualizer.print_success("Cleaned up existing demo data")

# Create sample user
SqlVisualizer.print_section("Step 2: Create Sample User")
user = User.create!(
  email_address: 'demo@example.com',
  password: 'password123',
  password_confirmation: 'password123'
)
SqlVisualizer.print_success("Created user: #{user.email_address}")

# Create a quiz
SqlVisualizer.print_section("Step 3: Create Sample Quiz")
quiz = Quiz.create!(
  title: "Music Theory Basics",
  difficulty: :easy,
  description: "Test your knowledge of basic music theory concepts"
)
SqlVisualizer.print_success("Created quiz: #{quiz.title}")

# Create questions with answers
SqlVisualizer.print_section("Step 4: Create Questions and Answers")

question1 = quiz.questions.create!(
  content: "What is the interval between C and E?",
  difficulty: :easy,
  topic: "intervals"
)

question1.answers.create!([
  { content: "Major third", correct: true },
  { content: "Minor third", correct: false },
  { content: "Perfect fourth", correct: false },
  { content: "Perfect fifth", correct: false }
])

question2 = quiz.questions.create!(
  content: "How many sharps are in the key of D Major?",
  difficulty: :easy,
  topic: "key_signatures"
)

question2.answers.create!([
  { content: "1", correct: false },
  { content: "2", correct: true },
  { content: "3", correct: false },
  { content: "0", correct: false }
])

question3 = quiz.questions.create!(
  content: "What notes make up a C Major chord?",
  difficulty: :easy,
  topic: "chords"
)

question3.answers.create!([
  { content: "C, E, G", correct: true },
  { content: "C, D, E", correct: false },
  { content: "C, F, G", correct: false },
  { content: "C, E♭, G", correct: false }
])

SqlVisualizer.print_success("Created #{quiz.questions.count} questions with answers")

# Disable SQL logging temporarily for cleaner output
ActiveRecord::Base.logger.level = Logger::WARN

# Display questions table
SqlVisualizer.print_section("Questions Created")
questions_data = quiz.questions.includes(:answers).map do |q|
  correct_answer = q.answers.find_by(correct: true)
  [ q.id, q.content[0..40] + "...", q.topic, correct_answer.content ]
end
SqlVisualizer.print_table(
  [ "ID", "Question", "Topic", "Correct Answer" ],
  questions_data
)

# Re-enable SQL logging
ActiveRecord::Base.logger.level = Logger::DEBUG

# Create a quiz attempt
SqlVisualizer.print_section("Step 5: Create Quiz Attempt")
quiz_attempt = QuizAttempt.create!(
  user: user,
  quiz: quiz,
  score: 0
)
SqlVisualizer.print_success("Created quiz attempt ##{quiz_attempt.id}")

# Simulate user answering questions
SqlVisualizer.print_section("Step 6: Record User Answers")

# User gets question 1 correct
answer1 = question1.answers.find_by(correct: true)
quiz_attempt.user_answers.create!(
  question: question1,
  answer: answer1
)
SqlVisualizer.print_success("Question 1: Correct! ✓")

# User gets question 2 correct
answer2 = question2.answers.find_by(correct: true)
quiz_attempt.user_answers.create!(
  question: question2,
  answer: answer2
)
SqlVisualizer.print_success("Question 2: Correct! ✓")

# User gets question 3 wrong
answer3 = question3.answers.find_by(content: "C, D, E")
quiz_attempt.user_answers.create!(
  question: question3,
  answer: answer3
)
SqlVisualizer.print_success("Question 3: Incorrect ✗")

# Calculate and update score
SqlVisualizer.print_section("Step 7: Calculate Score with JOIN")
SqlVisualizer.print_info("Now we'll use a JOIN to count correct answers...")

puts "\n#{SqlVisualizer::COLORS[:blue]}#{SqlVisualizer::COLORS[:bold]}The following SQL demonstrates an INNER JOIN:#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}We join user_answers with answers to check which answers were correct#{SqlVisualizer::COLORS[:reset]}\n"

# Re-enable logging to show the JOIN
ActiveRecord::Base.logger.level = Logger::DEBUG
correct_count = quiz_attempt.user_answers.joins(:answer).where(answers: { correct: true }).count
ActiveRecord::Base.logger.level = Logger::WARN

quiz_attempt.update!(
  score: correct_count,
  completed_at: Time.current
)

SqlVisualizer.print_success("Score calculated: #{correct_count}/#{quiz.questions.count}")

# Show the join visualization
SqlVisualizer.print_join_visualization(quiz_attempt)

# Display detailed results
SqlVisualizer.print_section("Step 8: Retrieve Complete Results with Multiple JOINs")

puts "#{SqlVisualizer::COLORS[:magenta]}To display the full results, Rails will perform multiple queries:#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}1. Load the quiz attempt#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}2. Load associated user answers#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}3. Load questions and answers through associations#{SqlVisualizer::COLORS[:reset]}\n"

ActiveRecord::Base.logger.level = Logger::DEBUG

# Eager load all associations to show the queries
result = QuizAttempt
  .includes(user_answers: [ :question, :answer ])
  .find(quiz_attempt.id)

ActiveRecord::Base.logger.level = Logger::WARN

# Display results table
SqlVisualizer.print_section("Quiz Attempt Results")

results_data = result.user_answers.map do |user_answer|
  [
    user_answer.question.content[0..45] + "...",
    user_answer.answer.content,
    user_answer.correct? ? "✓ Correct" : "✗ Wrong"
  ]
end

SqlVisualizer.print_table(
  [ "Question", "User's Answer", "Result" ],
  results_data
)

# Final summary
SqlVisualizer.print_header("SUMMARY")

summary_data = [
  [ "User", user.email_address ],
  [ "Quiz", quiz.title ],
  [ "Total Questions", quiz.questions.count ],
  [ "Correct Answers", correct_count ],
  [ "Score", "#{quiz_attempt.score_percentage}%" ],
  [ "Status", quiz_attempt.completed? ? "Completed ✓" : "In Progress" ]
]

SqlVisualizer.print_table(
  [ "Metric", "Value" ],
  summary_data
)

SqlVisualizer.print_section("Key SQL Concepts Demonstrated")

puts "#{SqlVisualizer::COLORS[:green]}1. INSERT#{SqlVisualizer::COLORS[:reset]} - Creating records (user, quiz, questions, answers)"
puts "#{SqlVisualizer::COLORS[:green]}2. SELECT#{SqlVisualizer::COLORS[:reset]} - Retrieving data"
puts "#{SqlVisualizer::COLORS[:green]}3. INNER JOIN#{SqlVisualizer::COLORS[:reset]} - Combining user_answers with answers to check correctness"
puts "#{SqlVisualizer::COLORS[:green]}4. WHERE#{SqlVisualizer::COLORS[:reset]} - Filtering for correct answers"
puts "#{SqlVisualizer::COLORS[:green]}5. COUNT#{SqlVisualizer::COLORS[:reset]} - Aggregating the number of correct answers"
puts "#{SqlVisualizer::COLORS[:green]}6. UPDATE#{SqlVisualizer::COLORS[:reset]} - Updating the score and completion time"
puts "#{SqlVisualizer::COLORS[:green]}7. Eager Loading#{SqlVisualizer::COLORS[:reset]} - Using includes() to optimize queries\n"

SqlVisualizer.print_header("DEMONSTRATION COMPLETE")

puts "#{SqlVisualizer::COLORS[:yellow]}To see raw SQL for any query, you can use:#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}  QuizAttempt.joins(:user_answers).to_sql#{SqlVisualizer::COLORS[:reset]}"
puts "#{SqlVisualizer::COLORS[:cyan]}  quiz_attempt.user_answers.joins(:answer).where(answers: { correct: true }).to_sql#{SqlVisualizer::COLORS[:reset]}\n"

# Clean up
SqlVisualizer.print_section("Cleanup")
puts "#{SqlVisualizer::COLORS[:yellow]}Would you like to keep this demo data? (y/n)#{SqlVisualizer::COLORS[:reset]}"
print "> "

response = STDIN.gets&.chomp&.downcase

if response == 'n' || response == 'no'
  user.destroy
  SqlVisualizer.print_success("Demo data cleaned up!")
else
  SqlVisualizer.print_info("Demo data preserved. User email: demo@example.com")
end

puts "\n#{SqlVisualizer::COLORS[:bold]}#{SqlVisualizer::COLORS[:green]}Done! 🎵#{SqlVisualizer::COLORS[:reset]}\n"
