require "test_helper"

class RoomTest < ActiveSupport::TestCase
  test "valid room" do
    room = Room.new(
      name: "Test Room",
      location: "Novosibirsk",
      price_per_hour: 100,
      user: users(:owner)
    )
    assert room.valid?
  end

  test "requires name and location" do
    room = Room.new(price_per_hour: 100, user: users(:owner))
    assert_not room.valid?
    assert_includes room.errors[:name], "can't be blank"
    assert_includes room.errors[:location], "can't be blank"
  end

  test "requires positive price per hour" do
    room = rooms(:active_room)
    room.price_per_hour = 0
    assert_not room.valid?
    assert_includes room.errors[:price_per_hour], "must be greater than or equal to 0.01"
  end

  test "requires user" do
    room = Room.new(name: "Test", location: "City", price_per_hour: 100)
    assert_not room.valid?
    assert_includes room.errors[:user_id], "can't be blank"
  end

  test "active scope returns only active rooms" do
    active = Room.active
    assert_includes active, rooms(:active_room)
    assert_not_includes active, rooms(:inactive_room)
  end

  test "available_at excludes rooms with overlapping bookings" do
    start_time = Time.zone.parse("2030-06-01 11:00:00")
    end_time = Time.zone.parse("2030-06-01 13:00:00")

    available = Room.available_at(start_time, end_time)
    assert_not_includes available, rooms(:active_room)
    assert_includes available, rooms(:other_owner_room)
  end

  test "available_at includes room when overlap is canceled" do
    start_time = Time.zone.parse("2030-06-01 15:00:00")
    end_time = Time.zone.parse("2030-06-01 17:00:00")

    available = Room.available_at(start_time, end_time)
    assert_includes available, rooms(:active_room)
  end

  test "occupied_slots returns non-canceled booking intervals" do
    slots = rooms(:active_room).occupied_slots
    assert_includes slots, [
      bookings(:confirmed_booking).start_time,
      bookings(:confirmed_booking).end_time
    ]
    assert_not_includes slots, [
      bookings(:canceled_booking).start_time,
      bookings(:canceled_booking).end_time
    ]
  end

  test "destroys associated bookings" do
    room = rooms(:other_owner_room)
    assert room.bookings.any?

    assert_difference "Booking.count", -room.bookings.count do
      room.destroy
    end
  end

  test "ransackable_attributes includes searchable fields" do
    attrs = Room.ransackable_attributes
    assert_includes attrs, "id"
    assert_includes attrs, "name"
    assert_includes attrs, "location"
    assert_includes attrs, "user_id"
    assert_includes attrs, "is_active"
  end

  test "ransackable_associations includes user and bookings" do
    assocs = Room.ransackable_associations
    assert_includes assocs, "user"
    assert_includes assocs, "bookings"
  end

  test "room belongs to user" do
    room = rooms(:active_room)
    assert_equal users(:owner), room.user
  end

  test "room has many bookings" do
    room = rooms(:active_room)
    assert room.bookings.any?
  end

  test "is_active defaults to true when not specified" do
    room = Room.create!(
      name: "New Room",
      location: "City",
      price_per_hour: 500,
      user: users(:owner)
    )
    assert room.is_active
  end

  test "occupied_slots returns empty for room with no bookings" do
    room = Room.create!(
      name: "Empty Room",
      location: "City",
      price_per_hour: 500,
      user: users(:owner)
    )
    assert_equal [], room.occupied_slots
  end
end
