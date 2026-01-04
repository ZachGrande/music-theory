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
end
