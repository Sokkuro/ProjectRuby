require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @room = rooms(:active_room)
    @client = users(:client)
  end

  test "GET new requires authentication" do
    get new_booking_path(room_id: @room.id)
    assert_redirected_to new_user_session_path
  end

  test "GET new shows booking form for authenticated user" do
    sign_in @client
    get new_booking_path(room_id: @room.id)
    assert_response :success
    assert_match @room.name, response.body
  end

  test "POST create requires authentication" do
    post bookings_path, params: {
      booking: {
        room_id: @room.id,
        start_time: "2030-09-01 10:00",
        end_time: "2030-09-01 12:00"
      }
    }
    assert_redirected_to new_user_session_path
  end

  test "POST create creates confirmed booking" do
    sign_in @client

    assert_difference "Booking.count", 1 do
      post bookings_path, params: {
        booking: {
          room_id: @room.id,
          start_time: "2030-09-01 10:00",
          end_time: "2030-09-01 12:00"
        }
      }
    end

    booking = Booking.order(:id).last
    assert_equal "confirmed", booking.status
    assert_equal @client, booking.user
    assert_equal 1000.0, booking.total_price.to_f
    assert_redirected_to my_bookings_path
    follow_redirect!
    assert_match "Бронь создана", response.body
  end

  test "POST create renders new on validation error" do
    sign_in @client

    assert_no_difference "Booking.count" do
      post bookings_path, params: {
        booking: {
          room_id: @room.id,
          start_time: "2030-06-01 11:00",
          end_time: "2030-06-01 13:00"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
