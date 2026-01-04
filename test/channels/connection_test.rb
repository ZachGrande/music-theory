require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with valid session cookie" do
    user = users(:one)
    session = user.sessions.create!

    # Simulate connecting with the session cookie
    cookies.signed[:session_id] = session.id

    connect

    assert_equal user, connection.current_user
  end

  test "rejects connection without session cookie" do
    assert_reject_connection { connect }
  end

  test "rejects connection with invalid session cookie" do
    cookies.signed[:session_id] = "invalid-session-id"

    assert_reject_connection { connect }
  end
end
