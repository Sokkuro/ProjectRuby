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

  test "POST create with overlapping booking fails" do
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
    assert_match "overlaps", response.body.downcase
  end

  test "GET new with non-existent room raises error" do
    sign_in @client
    assert_raises(ActiveRecord::RecordNotFound) do
      get new_booking_path(room_id: 99999)
    end
  end

  test "GET new with inactive room raises error" do
    sign_in @client
    assert_raises(ActiveRecord::RecordNotFound) do
      get new_booking_path(room_id: rooms(:inactive_room).id)
    end
  end

  test "POST create associates booking with signed-in user" do
    sign_in @client
    post bookings_path, params: {
      booking: {
        room_id: @room.id,
        start_time: "2030-09-02 10:00",
        end_time: "2030-09-02 12:00"
      }
    }

    booking = Booking.order(:id).last
    assert_equal @client.id, booking.user_id
  end

  test "POST create with future time slot succeeds" do
    sign_in @client
    future_date = (Time.current + 30.days).strftime("%Y-%m-%d")

    assert_difference "Booking.count", 1 do
      post bookings_path, params: {
        booking: {
          room_id: @room.id,
          start_time: "#{future_date} 10:00",
          end_time: "#{future_date} 12:00"
        }
      }
    end

    assert_redirected_to my_bookings_path
  end

  test "POST create assigns room correctly" do
    sign_in @client
    post bookings_path, params: {
      booking: {
        room_id: @room.id,
        start_time: "2030-09-03 10:00",
        end_time: "2030-09-03 12:00"
      }
    }

    booking = Booking.order(:id).last
    assert_equal @room, booking.room
  end

  test "POST create calculates price" do
    sign_in @client
    post bookings_path, params: {
      booking: {
        room_id: @room.id,
        start_time: "2030-09-04 10:00",
        end_time: "2030-09-04 14:00"
      }
    }

    booking = Booking.order(:id).last
    assert_equal 2000.0, booking.total_price.to_f
  end

  test "POST create with room_id from params" do
    sign_in @client
    other_room = rooms(:other_owner_room)

    post bookings_path, params: {
      booking: {
        room_id: other_room.id,
        start_time: "2030-09-05 09:00",
        end_time: "2030-09-05 11:00"
      }
    }

    booking = Booking.order(:id).last
    assert_equal other_room, booking.room
  end
end
