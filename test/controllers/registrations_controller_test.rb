require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  # New action
  test "new renders registration form" do
    get new_registration_path
    assert_response :success
  end

  test "new is accessible without authentication" do
    get new_registration_path
    assert_response :success
  end

  # Create action - valid params
  test "create with valid params creates user" do
    assert_difference "User.count", 1 do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  test "create with valid params redirects to dashboard" do
    post registration_path, params: {
      user: {
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_redirected_to dashboard_path
  end

  test "create with valid params starts session" do
    post registration_path, params: {
      user: {
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    user = User.find_by(email_address: "newuser@example.com")
    assert user.sessions.exists?
  end

  test "create with valid params shows welcome notice" do
    post registration_path, params: {
      user: {
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    assert_equal "Welcome to Music Theory Quiz!", flash[:notice]
  end

  # Create action - invalid params
  test "create with missing password renders form with errors" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "",
          password_confirmation: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with mismatched password confirmation renders form with errors" do
    assert_no_difference "User.count" do
      post registration_path, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "create with duplicate email raises database error" do
    create(:user, email_address: "existing@example.com")

    assert_raises(ActiveRecord::RecordNotUnique) do
      post registration_path, params: {
        user: {
          email_address: "existing@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end
  end

  # Email normalization
  test "create normalizes email address" do
    post registration_path, params: {
      user: {
        email_address: "  TEST@EXAMPLE.COM  ",
        password: "password123",
        password_confirmation: "password123"
      }
    }

    user = User.last
    assert_equal "test@example.com", user.email_address
  end

  # Strong parameters
  test "create ignores non-permitted attributes" do
    post registration_path, params: {
      user: {
        email_address: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
        current_streak: 100,
        longest_streak: 100
      }
    }

    user = User.find_by(email_address: "newuser@example.com")
    assert_equal 0, user.current_streak
    assert_equal 0, user.longest_streak
  end
end
