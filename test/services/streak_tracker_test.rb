require "test_helper"

class StreakTrackerTest < ActiveSupport::TestCase
  test "first quiz ever sets streak to 1" do
    user = create(:user, current_streak: 0, longest_streak: 0, last_quiz_date: nil)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 1, user.current_streak
    assert_equal 1, user.longest_streak
    assert_equal Date.current, user.last_quiz_date
  end

  test "same day quiz does not change streak" do
    user = create(:user, current_streak: 3, longest_streak: 5, last_quiz_date: Date.current)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 3, user.current_streak
    assert_equal 5, user.longest_streak
    assert_equal Date.current, user.last_quiz_date
  end

  test "consecutive day increments streak" do
    user = create(:user, :streak_yesterday)
    original_streak = user.current_streak

    StreakTracker.new(user).update!

    user.reload
    assert_equal original_streak + 1, user.current_streak
    assert_equal Date.current, user.last_quiz_date
  end

  test "gap of two or more days resets streak to 1" do
    user = create(:user, :streak_broken)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 1, user.current_streak
    assert_equal Date.current, user.last_quiz_date
  end

  test "updates longest streak when current exceeds it" do
    user = create(:user, current_streak: 5, longest_streak: 5, last_quiz_date: Date.current - 1.day)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 6, user.current_streak
    assert_equal 6, user.longest_streak
  end

  test "does not update longest streak when current is less" do
    user = create(:user, current_streak: 2, longest_streak: 10, last_quiz_date: Date.current - 1.day)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 3, user.current_streak
    assert_equal 10, user.longest_streak
  end

  test "streak reset preserves longest streak" do
    user = create(:user, current_streak: 5, longest_streak: 10, last_quiz_date: Date.current - 5.days)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 1, user.current_streak
    assert_equal 10, user.longest_streak
  end

  test "first quiz sets longest streak to 1" do
    user = create(:user, current_streak: 0, longest_streak: 0, last_quiz_date: nil)

    StreakTracker.new(user).update!

    user.reload
    assert_equal 1, user.longest_streak
  end

  test "quiz on exact yesterday boundary increments streak" do
    travel_to Time.zone.local(2026, 1, 3, 10, 0, 0) do
      user = create(:user, current_streak: 2, longest_streak: 2, last_quiz_date: Date.new(2026, 1, 2))

      StreakTracker.new(user).update!

      user.reload
      assert_equal 3, user.current_streak
    end
  end

  test "quiz two days ago resets streak" do
    travel_to Time.zone.local(2026, 1, 3, 10, 0, 0) do
      user = create(:user, current_streak: 5, longest_streak: 5, last_quiz_date: Date.new(2026, 1, 1))

      StreakTracker.new(user).update!

      user.reload
      assert_equal 1, user.current_streak
    end
  end
end
