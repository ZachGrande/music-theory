require "test_helper"

class SessionTest < ActiveSupport::TestCase
  # Validations
  test "valid session" do
    session = build(:session)
    assert session.valid?
  end

  test "requires user association" do
    session = build(:session, user: nil)
    assert_not session.valid?
  end

  # Associations
  test "belongs to user" do
    user = create(:user)
    session = create(:session, user: user)
    assert_equal user, session.user
  end

  # Attributes
  test "stores ip address" do
    session = create(:session, ip_address: "192.168.1.1")
    assert_equal "192.168.1.1", session.ip_address
  end

  test "stores user agent" do
    session = create(:session, user_agent: "Mozilla/5.0")
    assert_equal "Mozilla/5.0", session.user_agent
  end

  test "allows nil ip address" do
    session = build(:session, ip_address: nil)
    assert session.valid?
  end

  test "allows nil user agent" do
    session = build(:session, user_agent: nil)
    assert session.valid?
  end
end
