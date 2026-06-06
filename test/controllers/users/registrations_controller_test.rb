require "test_helper"

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "after sign up redirects to root path" do
      post "/users", params: {
        user: {
          email: "newuser@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      assert_redirected_to root_path
    end

    test "sign up creates new user" do
      assert_difference "User.count", 1 do
        post "/users", params: {
          user: {
            email: "brand_new@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end
    end

    test "new user is created as client" do
      post "/users", params: {
        user: {
          email: "another_new@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }

      user = User.last
      assert_equal "client", user.role
    end

    test "get registration form is accessible" do
      get "/users/sign_up"
      assert_response :success
    end

    test "sign up with invalid email fails" do
      assert_no_difference "User.count" do
        post "/users", params: {
          user: {
            email: "client@example.com", # Already exists
            password: "password",
            password_confirmation: "password"
          }
        }
      end
    end

    test "sign up with mismatched passwords fails" do
      assert_no_difference "User.count" do
        post "/users", params: {
          user: {
            email: "mismatch@example.com",
            password: "password",
            password_confirmation: "different"
          }
        }
      end
    end
  end
end
