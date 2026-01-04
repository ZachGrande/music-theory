require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "authenticated? returns true when user is present" do
    user = users(:one)
    Current.session = user.sessions.create!

    assert authenticated?
  end

  test "authenticated? returns false when user is not present" do
    Current.session = nil

    assert_not authenticated?
  end

  test "score_color_class returns green for scores 80 and above" do
    assert_equal "bg-green-100 text-green-800", score_color_class(80)
    assert_equal "bg-green-100 text-green-800", score_color_class(100)
    assert_equal "bg-green-100 text-green-800", score_color_class(95)
  end

  test "score_color_class returns amber for scores 60 to 79" do
    assert_equal "bg-amber-100 text-amber-800", score_color_class(60)
    assert_equal "bg-amber-100 text-amber-800", score_color_class(79)
    assert_equal "bg-amber-100 text-amber-800", score_color_class(70)
  end

  test "score_color_class returns red for scores below 60" do
    assert_equal "bg-red-100 text-red-800", score_color_class(59)
    assert_equal "bg-red-100 text-red-800", score_color_class(0)
    assert_equal "bg-red-100 text-red-800", score_color_class(30)
  end

  test "score_color returns correct text colors" do
    assert_equal "text-green-500", score_color(85)
    assert_equal "text-amber-500", score_color(65)
    assert_equal "text-red-500", score_color(40)
  end

  test "difficulty_badge returns styled span for each difficulty" do
    easy_badge = difficulty_badge("easy")
    assert_includes easy_badge, "Easy"
    assert_includes easy_badge, "bg-green-100"

    medium_badge = difficulty_badge("medium")
    assert_includes medium_badge, "Medium"
    assert_includes medium_badge, "bg-amber-100"

    hard_badge = difficulty_badge("hard")
    assert_includes hard_badge, "Hard"
    assert_includes hard_badge, "bg-red-100"
  end
end
