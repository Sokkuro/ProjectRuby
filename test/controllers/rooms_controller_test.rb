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
end
