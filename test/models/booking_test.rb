require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "valid booking" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      start_time: Time.zone.parse("2030-07-01 10:00:00"),
      end_time: Time.zone.parse("2030-07-01 12:00:00"),
      status: "pending"
    )
    assert booking.valid?
  end

  test "requires start and end time" do
    booking = Booking.new(room: rooms(:active_room), user: users(:client), status: "pending")
    assert_not booking.valid?
    assert_includes booking.errors[:start_time], "can't be blank"
    assert_includes booking.errors[:end_time], "can't be blank"
  end

  test "validates status inclusion" do
    booking = bookings(:confirmed_booking)
    booking.status = "invalid"
    assert_not booking.valid?
    assert_includes booking.errors[:status], "is not included in the list"
  end

  test "end time must be after start time" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      start_time: Time.zone.parse("2030-07-01 12:00:00"),
      end_time: Time.zone.parse("2030-07-01 10:00:00"),
      status: "pending"
    )
    assert_not booking.valid?
    assert_includes booking.errors[:end_time], "must be after start time"
  end

  test "rejects overlapping bookings for same room" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:other_client),
      start_time: Time.zone.parse("2030-06-01 11:00:00"),
      end_time: Time.zone.parse("2030-06-01 13:00:00"),
      status: "confirmed"
    )
    assert_not booking.valid?
    assert_includes booking.errors[:base], "Time slot overlaps with an existing booking"
  end

  test "allows overlapping time when existing booking is canceled" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:other_client),
      start_time: Time.zone.parse("2030-06-01 15:00:00"),
      end_time: Time.zone.parse("2030-06-01 16:00:00"),
      status: "confirmed"
    )
    assert booking.valid?
  end

  test "calculate_price returns price based on duration" do
    room = rooms(:active_room)
    start_time = Time.zone.parse("2030-07-01 10:00:00")
    end_time = Time.zone.parse("2030-07-01 13:00:00")

    assert_equal 1500.0, Booking.calculate_price(room, start_time, end_time)
  end

  test "calculates total price before validation on create" do
    booking = Booking.create!(
      room: rooms(:active_room),
      user: users(:client),
      start_time: Time.zone.parse("2030-08-01 10:00:00"),
      end_time: Time.zone.parse("2030-08-01 12:00:00"),
      status: "pending"
    )
    assert_equal 1000.0, booking.total_price.to_f
  end

  test "duration_hours returns booking length in hours" do
    booking = bookings(:confirmed_booking)
    assert_equal 2.0, booking.duration_hours
  end

  test "overlapping scope finds intersecting bookings" do
    start_time = Time.zone.parse("2030-06-01 11:00:00")
    end_time = Time.zone.parse("2030-06-01 13:00:00")

    overlaps = Booking.overlapping(start_time, end_time, rooms(:active_room).id)
    assert_includes overlaps, bookings(:confirmed_booking)
    assert_not_includes overlaps, bookings(:canceled_booking)
  end
end
