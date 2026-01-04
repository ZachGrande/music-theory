require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "reset email is sent to user" do
    user = users(:one)
    email = PasswordsMailer.reset(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "from@example.com" ], email.from
    assert_equal [ user.email_address ], email.to
    assert_equal "Reset your password", email.subject
  end
end
