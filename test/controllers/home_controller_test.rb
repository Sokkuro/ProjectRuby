require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "GET root shows home page" do
    get root_path
    assert_response :success
    assert_select "body"
  end

  test "home page lists recent active rooms" do
    get root_path
    assert_response :success
    assert_match rooms(:active_room).name, response.body
    assert_no_match rooms(:inactive_room).name, response.body
  end
end
