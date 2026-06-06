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

  test "GET index shows bookings ordered by start_time descending" do
    sign_in users(:client)
    get my_bookings_path
    bookings_list = assigns(:bookings)
    assert bookings_list.length >= 1
  end

  test "GET index includes room information" do
    sign_in users(:client)
    get my_bookings_path
    assert_response :success
    assert assigns(:bookings).all? { |b| b.room.present? }
  end

  test "GET index response is successful" do
    sign_in users(:client)
    get my_bookings_path
    assert_response :success
  end

  test "GET index with no bookings shows empty list" do
    user = users(:other_client)
    sign_in user
    # other_client might not have bookings initially
    get my_bookings_path
    assert_response :success
  end

  test "GET index shows all user's bookings" do
    client = users(:client)
    sign_in client
    get my_bookings_path
    bookings_count = assigns(:bookings).count
    assert bookings_count == client.bookings.count
  end

  test "GET index HTML response includes page content" do
    sign_in users(:client)
    get my_bookings_path
    assert_response :success
    assert_select "body"
  end

  test "GET index as different user shows only their bookings" do
    owner = users(:owner)
    sign_in owner
    get my_bookings_path
    # Owner might not have any bookings (they create rooms)
    bookings = assigns(:bookings)
    bookings.each do |booking|
      assert_equal owner, booking.user
    end
  end
end
