require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # test "authenticates password" do
  test "create user" do
    user = User.create({screenname: "Plastic",
                email: "123@xyz.hi",
                password: "12341234"})

    # Reload the user (Otherwise password will not be nil)
    user = User.find(user)

    assert_equal user.screenname, "Plastic"
    assert_equal user.email, "123@xyz.hi"

    # Ensure user password in nil (not accessible)
    assert_nil user.password

    # Ensure reports that user has password.
    assert user.has_password?
    # Ensure password can be authenticated.
    assert user.authenticate("12341234")
    # Ensure authenticate returns false for wrong password.
    assert_not user.authenticate("43214321")

  ensure
    user.delete
  end

  test "Find user by email" do
    # user = User.create(email: "123@xyz.net")

    user = User.create(screenname: "Plastic",
                       email: "123@xyz.net",
                       password: "12341234")

    user = User.find_by(email: "123@xyz.net")
    assert_equal user.email, "123@xyz.net"

  ensure
    user.delete
  end

  test "email is not required" do
    user = User.create(screenname: "Plastic",
                       password: "12341234")

    user = User.last
    assert_equal "Plastic", user.screenname
  ensure
    user.delete
  end

end
