require "test_helper"

class ModelAssociationsTest < ActionDispatch::IntegrationTest
  test "user has many bookings" do
    user = users(:client)
    assert user.bookings.any?
  end

  test "user has many rooms" do
    user = users(:owner)
    assert user.rooms.any?
  end

  test "room has many bookings" do
    room = rooms(:active_room)
    assert room.bookings.any?
  end

  test "booking belongs to room" do
    booking = bookings(:confirmed_booking)
    assert_equal rooms(:active_room), booking.room
  end

  test "booking belongs to user" do
    booking = bookings(:confirmed_booking)
    assert_equal users(:client), booking.user
  end

  test "room belongs to user" do
    room = rooms(:active_room)
    assert_equal users(:owner), room.user
  end

  test "deleting user deletes bookings" do
    user = User.create!(
      email: "temp_user@example.com",
      password: "password",
      password_confirmation: "password",
      role: "client"
    )

    booking = Booking.create!(
      room: rooms(:active_room),
      user: user,
      start_time: Time.zone.parse("2030-12-01 10:00:00"),
      end_time: Time.zone.parse("2030-12-01 12:00:00"),
      status: "pending"
    )

    booking_id = booking.id
    user.destroy

    assert_not Booking.exists?(booking_id)
  end

  test "deleting room deletes bookings" do
    owner = User.create!(
      email: "temp_owner@example.com",
      password: "password",
      password_confirmation: "password",
      role: "owner"
    )

    room = Room.create!(
      name: "Temp Room",
      location: "Temp City",
      price_per_hour: 500,
      user: owner
    )

    booking = Booking.create!(
      room: room,
      user: users(:client),
      start_time: Time.zone.parse("2030-11-01 10:00:00"),
      end_time: Time.zone.parse("2030-11-01 12:00:00"),
      status: "pending"
    )

    booking_id = booking.id
    room.destroy

    assert_not Booking.exists?(booking_id)
  end

  test "booking statuses are correct" do
    assert_includes Booking::STATUSES, "pending"
    assert_includes Booking::STATUSES, "confirmed"
    assert_includes Booking::STATUSES, "canceled"
  end

  test "user roles are correct" do
    assert_includes User::ROLES, "client"
    assert_includes User::ROLES, "owner"
    assert_includes User::ROLES, "admin"
  end
end
