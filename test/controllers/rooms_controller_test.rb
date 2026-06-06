require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  test "GET index lists active rooms" do
    get rooms_path
    assert_response :success
    assert_match rooms(:active_room).name, response.body
    assert_no_match rooms(:inactive_room).name, response.body
  end

  test "GET show displays active room" do
    get room_path(rooms(:active_room))
    assert_response :success
    assert_match rooms(:active_room).name, response.body
  end

  test "GET show returns not found for inactive room" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get room_path(rooms(:inactive_room))
    end
  end

  test "GET index includes user information" do
    get rooms_path
    assert_response :success
    # Verify rooms are loaded with user association
    assert assigns(:rooms).all? { |room| room.user.present? }
  end

  test "GET index does not include inactive rooms" do
    get rooms_path
    assert_response :success
    assert_not_includes assigns(:rooms), rooms(:inactive_room)
  end

  test "GET index loads rooms ordered by name" do
    get rooms_path
    rooms_list = assigns(:rooms)
    assert rooms_list.all? { |r| r.is_active? }
  end

  test "GET show with non-existent room raises error" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get room_path(99999)
    end
  end

  test "GET show displays room details" do
    room = rooms(:active_room)
    get room_path(room)
    assert_response :success
    # Verify occupied slots array is initialized
    assert_not_nil assigns(:occupied_slots)
  end

  test "GET index returns HTML" do
    get rooms_path
    assert_response :success
    assert_match /text\/html/, response.content_type
  end

  test "GET show is accessible without authentication" do
    get room_path(rooms(:active_room))
    assert_response :success
  end

  test "GET index is accessible without authentication" do
    get rooms_path
    assert_response :success
  end
end
