require "test_helper"

class AvailabilityTest < ActionDispatch::IntegrationTest
  test "room availability changes with confirmed booking" do
    room = rooms(:other_owner_room)  # Use room with fewer bookings
    start_time = Time.zone.parse("2030-07-01 10:00:00")
    end_time = Time.zone.parse("2030-07-01 12:00:00")

    # Should be available initially
    available_before = Room.available_at(start_time, end_time)
    assert available_before.exists?

    # Create overlapping booking
    booking = Booking.create!(
      room: room,
      user: users(:client),
      start_time: start_time,
      end_time: end_time,
      status: "confirmed"
    )

    # Should not be available now
    available_after = Room.available_at(start_time, end_time)
    assert_not available_after.exists?(room.id)

    # Cancel booking
    booking.update(status: "canceled")

    # Should be available again
    available_final = Room.available_at(start_time, end_time)
    assert available_final.exists?(room.id)
  end

  test "booking validation with edge times" do
    room = rooms(:active_room)

    # Test booking that ends exactly when another starts (should be allowed)
    booking1 = bookings(:confirmed_booking)
    booking2 = Booking.new(
      room: room,
      user: users(:other_client),
      start_time: booking1.end_time,
      end_time: booking1.end_time + 2.hours,
      status: "confirmed"
    )

    assert booking2.valid?
  end

  test "price calculation accuracy" do
    room = rooms(:active_room)
    start = Time.zone.parse("2030-07-01 09:00:00")

    # Test 1 hour
    end_1h = start + 1.hour
    assert_equal 500.0, Booking.calculate_price(room, start, end_1h)

    # Test 2.5 hours
    end_2_5h = start + 2.5.hours
    assert_equal 1250.0, Booking.calculate_price(room, start, end_2_5h)

    # Test fractional hours
    end_30min = start + 30.minutes
    assert_equal 250.0, Booking.calculate_price(room, start, end_30min)
  end

  test "user role transitions" do
    user = users(:client)
    assert user.client?
    assert_not user.owner?
    assert_not user.admin?

    user.role = "owner"
    assert user.owner?
    assert_not user.client?
    assert_not user.admin?

    user.role = "admin"
    assert user.admin?
    assert_not user.client?
    assert_not user.owner?
  end

  test "room active scope filtering" do
    all_rooms = Room.all
    active_rooms = Room.active

    assert active_rooms.count < all_rooms.count
    assert active_rooms.all? { |r| r.is_active? }
    assert_not active_rooms.any? { |r| !r.is_active? }
  end

  test "booking overlap detection with same exact times" do
    room = rooms(:active_room)
    start = Time.zone.parse("2030-06-01 10:00:00")
    end_time = Time.zone.parse("2030-06-01 12:00:00")

    # Create exact duplicate booking attempt
    booking = Booking.new(
      room: room,
      user: users(:other_client),
      start_time: start,
      end_time: end_time,
      status: "confirmed"
    )

    assert_not booking.valid?
    assert booking.errors[:base].present?
  end

  test "ransack search capability" do
    bookings = Booking.ransack(status_eq: "confirmed").result

    bookings.each do |booking|
      assert_equal "confirmed", booking.status
    end
  end
end
