require "test_helper"

class MyBookingsControllerTest < ActionDispatch::IntegrationTest
  test "GET index requires authentication" do
    get my_bookings_path
    assert_redirected_to new_user_session_path
  end

  test "GET index shows current user bookings" do
    sign_in users(:client)
    get my_bookings_path
    assert_response :success
    assert_match rooms(:active_room).name, response.body
    assert_match rooms(:other_owner_room).name, response.body
  end

  test "GET index does not show other users bookings" do
    sign_in users(:other_client)
    get my_bookings_path
    assert_response :success
    assert_no_match rooms(:other_owner_room).name, response.body
  end
end
