require "test_helper"

class GithubAuthControllerTest < ActionDispatch::IntegrationTest
  test "GET show is accessible" do
    get github_auth_path
    assert_response :success
  end

  test "GET show returns HTML" do
    get github_auth_path
    assert_match /text\/html/, response.content_type
  end

  test "GET show does not require authentication" do
    get github_auth_path
    assert_response :success
  end
end
