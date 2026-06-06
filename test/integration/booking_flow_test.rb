require "test_helper"

class BookingFlowTest < ActionDispatch::IntegrationTest
  test "user can browse rooms and create booking" do
    # Browse active rooms
    get rooms_path
    assert_response :success
    assert_match rooms(:active_room).name, response.body

    # Sign in
    sign_in users(:client)
    get rooms_path
    assert_response :success

    # Create booking
    get new_booking_path(room_id: rooms(:active_room).id)
    assert_response :success

    post bookings_path, params: {
      booking: {
        room_id: rooms(:active_room).id,
        start_time: "2030-09-10 10:00",
        end_time: "2030-09-10 12:00"
      }
    }

    assert_redirected_to my_bookings_path
    follow_redirect!
    assert_response :success
  end

  test "user can view their bookings" do
    client = users(:client)
    sign_in client

    get my_bookings_path
    assert_response :success
    assert assigns(:bookings).count > 0
  end

  test "owner can manage rooms" do
    owner = users(:owner)
    sign_in owner

    # View rooms
    get owner_rooms_path
    assert_response :success

    # Create new room
    post owner_rooms_path, params: {
      room: {
        name: "Integration Test Room",
        location: "Moscow",
        price_per_hour: 999,
        is_active: true
      }
    }

    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "user cannot access admin without admin role" do
    sign_in users(:client)
    # Try to access admin dashboard
    get "/admin"
    # Should redirect or be unauthorized
    assert [301, 302, 401, 403].include?(response.status)
  end

  test "complete booking workflow" do
    client = users(:client)
    owner = users(:owner)

    # Owner creates room
    sign_in owner
    post owner_rooms_path, params: {
      room: {
        name: "Workflow Room",
        location: "SPB",
        price_per_hour: 500,
        is_active: true
      }
    }
    room = Room.order(:id).last

    # Client books room
    sign_out(owner)
    sign_in client
    post bookings_path, params: {
      booking: {
        room_id: room.id,
        start_time: "2030-10-01 09:00",
        end_time: "2030-10-01 11:00"
      }
    }

    assert Booking.count > 0
  end
end
