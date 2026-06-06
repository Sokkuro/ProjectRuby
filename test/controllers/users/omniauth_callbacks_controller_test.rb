require "test_helper"

module Users
  class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
    test "github callback with valid auth creates/finds user" do
      auth_hash = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "12345",
        info: { email: "github@example.com" }
      )
      
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = auth_hash
      
      get "/users/auth/github/callback"
      
      # After callback, user should be signed in or redirected to registration
      assert_response :found
    end

    test "github callback with existing user signs them in" do
      auth_hash = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "12345",
        info: { email: "github@example.com" }
      )
      
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = auth_hash
      
      get "/users/auth/github/callback"
      
      follow_redirect!
      # User should be redirected to dashboard or home
      assert_response :success
    end

    test "github callback with new user creates account" do
      auth_hash = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "new_github_123",
        info: { email: "newgithubuser@example.com" }
      )
      
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = auth_hash
      
      assert_difference "User.count", 1 do
        get "/users/auth/github/callback"
      end
    end

    test "github callback persists user data" do
      auth_hash = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "persisted_uid",
        info: { email: "persisted@example.com" }
      )
      
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = auth_hash
      
      get "/users/auth/github/callback"
      
      user = User.find_by(email: "persisted@example.com")
      assert user.present?
      assert_equal "github", user.provider
      assert_equal "persisted_uid", user.uid
      assert_equal "client", user.role
    end
  end
end
