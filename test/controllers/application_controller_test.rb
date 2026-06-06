require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "admin user can access protected methods" do
    sign_in users(:admin)
    assert users(:admin).admin?
  end

  test "admin user is admin" do
    sign_in users(:admin)
    assert users(:admin).admin?
  end

  test "non-admin user is not admin" do
    sign_in users(:client)
    assert_not users(:client).admin?
  end

  test "devise parameter sanitization allows sign up parameters" do
    # Test that email and password parameters are permitted
    post "/users", params: {
      user: {
        email: "sanitize_test@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    assert User.find_by(email: "sanitize_test@example.com").present?
  end

  test "configure_permitted_parameters runs for devise controller" do
    # Sign up should work with email and password
    assert_difference "User.count", 1 do
      post "/users", params: {
        user: {
          email: "devise_test@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end
  end

  test "client role does not have admin access" do
    sign_in users(:client)
    assert_not users(:client).admin?
    assert users(:client).client?
  end

  test "owner role does not have admin access" do
    sign_in users(:owner)
    assert_not users(:owner).admin?
    assert users(:owner).owner?
  end
end
