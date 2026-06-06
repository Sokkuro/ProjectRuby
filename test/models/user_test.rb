require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user" do
    user = User.new(
      email: "new@example.com",
      password: "password",
      password_confirmation: "password",
      role: "client"
    )
    assert user.valid?
  end

  test "default role is client on create" do
    user = User.create!(
      email: "new@example.com",
      password: "password",
      password_confirmation: "password"
    )
    assert_equal "client", user.role
  end

  test "requires email" do
    user = User.new(password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "requires unique email case insensitive" do
    user = User.new(
      email: "CLIENT@example.com",
      password: "password",
      password_confirmation: "password"
    )
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "validates role inclusion" do
    user = users(:client)
    user.role = "superuser"
    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end

  test "role predicate methods" do
    assert users(:client).client?
    assert users(:owner).owner?
    assert users(:admin).admin?
    assert_not users(:client).admin?
  end

  test "destroys associated bookings" do
    client = users(:client)
    assert client.bookings.any?

    assert_difference "Booking.count", -client.bookings.count do
      client.destroy
    end
  end

  test "from_omniauth finds existing user by provider and uid" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "12345",
      info: { email: "github@example.com" }
    )

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal users(:github_user), user
    end
  end

  test "from_omniauth creates new client user" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "99999",
      info: { email: "newgithub@example.com" }
    )

    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth)
      assert_equal "newgithub@example.com", user.email
      assert_equal "client", user.role
      assert_equal "github", user.provider
      assert_equal "99999", user.uid
    end
  end

  test "from_omniauth generates secure password for new users" do
    auth = OmniAuth::AuthHash.new(
      provider: "github",
      uid: "55555",
      info: { email: "test@github.com" }
    )

    user = User.from_omniauth(auth)
    assert user.encrypted_password.present?
  end

  test "ransackable_attributes includes key fields" do
    attrs = User.ransackable_attributes
    assert_includes attrs, "id"
    assert_includes attrs, "email"
    assert_includes attrs, "role"
    assert_includes attrs, "provider"
  end

  test "ransackable_associations includes bookings and rooms" do
    assocs = User.ransackable_associations
    assert_includes assocs, "bookings"
    assert_includes assocs, "rooms"
  end

  test "destroys associated rooms on user deletion" do
    owner = users(:owner)
    original_room_count = owner.rooms.count
    assert original_room_count > 0

    assert_difference "Room.count", -original_room_count do
      owner.destroy
    end
  end

  test "owner role predicate is accurate" do
    owner = users(:owner)
    assert_not owner.client?
    assert owner.owner?
    assert_not owner.admin?
  end

  test "admin role predicate is accurate" do
    admin = users(:admin)
    assert_not admin.client?
    assert_not admin.owner?
    assert admin.admin?
  end

  test "user can have multiple bookings" do
    client = users(:client)
    assert client.bookings.count >= 1
  end

  test "user can have multiple rooms" do
    owner = users(:owner)
    assert owner.rooms.count >= 1
  end
end
