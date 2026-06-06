require "test_helper"

class Owner::RoomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner = users(:owner)
    @client = users(:client)
    @room = rooms(:active_room)
  end

  test "GET index requires owner role" do
    sign_in @client
    get owner_rooms_path
    assert_redirected_to root_path
    assert_equal "Owners only.", flash[:alert]
  end

  test "GET index lists owner rooms" do
    sign_in @owner
    get owner_rooms_path
    assert_response :success
    assert_match @room.name, response.body
  end

  test "GET show displays room details" do
    sign_in @owner
    get owner_room_path(@room)
    assert_response :success
    assert_match @room.name, response.body
  end

  test "GET new renders form" do
    sign_in @owner
    get new_owner_room_path
    assert_response :success
  end

  test "POST create adds room for owner" do
    sign_in @owner

    assert_difference "Room.count", 1 do
      post owner_rooms_path, params: {
        room: {
          name: "New Space",
          location: "Sochi",
          price_per_hour: 600,
          is_active: true
        }
      }
    end

    room = Room.order(:id).last
    assert_equal @owner, room.user
    assert_redirected_to owner_room_path(room)
  end

  test "PATCH update changes room attributes" do
    sign_in @owner

    patch owner_room_path(@room), params: {
      room: { name: "Updated Room Name" }
    }

    assert_redirected_to owner_room_path(@room)
    assert_equal "Updated Room Name", @room.reload.name
  end

  test "DELETE destroy removes room" do
    sign_in @owner
    room = rooms(:inactive_room)

    assert_difference "Room.count", -1 do
      delete owner_room_path(room)
    end

    assert_redirected_to owner_rooms_path
  end

  test "owner cannot access another users room" do
    other_owner = User.create!(
      email: "another-owner@example.com",
      password: "password",
      password_confirmation: "password",
      role: "owner"
    )
    foreign_room = other_owner.rooms.create!(
      name: "Foreign Room",
      location: "Vladivostok",
      price_per_hour: 400
    )

    sign_in @owner
    assert_raises(ActiveRecord::RecordNotFound) do
      get owner_room_path(foreign_room)
    end
  end
end
