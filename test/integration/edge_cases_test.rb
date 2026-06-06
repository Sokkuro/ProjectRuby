require "test_helper"

class EdgeCasesTest < ActionDispatch::IntegrationTest
  test "booking with same start and end time fails validation" do
    start_time = Time.current
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      start_time: start_time,
      end_time: start_time,
      status: "pending"
    )
    
    assert_not booking.valid?
    assert_includes booking.errors[:end_time], "must be after start time"
  end

  test "booking with negative duration fails validation" do
    start = Time.current
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      start_time: start,
      end_time: start - 1.hour,
      status: "pending"
    )
    
    assert_not booking.valid?
  end

  test "booking with blank times fails validation" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      status: "pending"
    )
    
    assert_not booking.valid?
    assert booking.errors[:start_time].present?
    assert booking.errors[:end_time].present?
  end

  test "room requires user association" do
    room = Room.new(
      name: "Test",
      location: "Test",
      price_per_hour: 100
    )
    
    assert_not room.valid?
  end

  test "room with zero price fails validation" do
    room = Room.new(
      name: "Test",
      location: "Test",
      price_per_hour: 0,
      user: users(:owner)
    )
    
    assert_not room.valid?
  end

  test "room with negative price fails validation" do
    room = Room.new(
      name: "Test",
      location: "Test",
      price_per_hour: -100,
      user: users(:owner)
    )
    
    assert_not room.valid?
  end

  test "user with duplicate email fails" do
    user = User.new(
      email: "client@example.com",
      password: "password",
      password_confirmation: "password",
      role: "client"
    )
    
    assert_not user.valid?
  end

  test "user with blank email fails" do
    user = User.new(
      password: "password",
      password_confirmation: "password",
      role: "client"
    )
    
    assert_not user.valid?
  end

  test "user with invalid role fails" do
    user = User.new(
      email: "test@example.com",
      password: "password",
      password_confirmation: "password",
      role: "superadmin"
    )
    
    assert_not user.valid?
  end

  test "booking with invalid status fails" do
    booking = Booking.new(
      room: rooms(:active_room),
      user: users(:client),
      start_time: Time.current + 1.day,
      end_time: Time.current + 1.day + 2.hours,
      status: "invalid_status"
    )
    
    assert_not booking.valid?
  end

  test "room name is required" do
    room = Room.new(
      name: nil,
      location: "Test",
      price_per_hour: 100,
      user: users(:owner)
    )
    
    assert_not room.valid?
  end

  test "room location is required" do
    room = Room.new(
      name: "Test",
      location: nil,
      price_per_hour: 100,
      user: users(:owner)
    )
    
    assert_not room.valid?
  end
end
