class StreakTracker
  def initialize(user)
    @user = user
  end

  def update!
    today = Date.current

    if @user.last_quiz_date.nil?
      # First quiz ever
      start_new_streak(today)
    elsif @user.last_quiz_date == today
      # Already took a quiz today, no change
      return
    elsif @user.last_quiz_date == today - 1.day
      # Consecutive day - increment streak
      increment_streak(today)
    else
      # Streak broken - start fresh
      start_new_streak(today)
    end
  end

  private

  def start_new_streak(date)
    @user.update!(
      current_streak: 1,
      last_quiz_date: date,
      longest_streak: [ @user.longest_streak, 1 ].max
    )
  end

  def increment_streak(date)
    new_streak = @user.current_streak + 1
    @user.update!(
      current_streak: new_streak,
      last_quiz_date: date,
      longest_streak: [ @user.longest_streak, new_streak ].max
    )
  end
end
