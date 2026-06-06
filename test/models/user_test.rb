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
end
