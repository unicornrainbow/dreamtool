require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "authenticates password" do
  test "create user" do
    user = User.create({screenname: "Plastic",
                email: "123@xyz.hi",
                password: "12341234"})

    user = User.find(user)

    assert_equal user.screenname, "Plastic"
    assert_equal user.email, "123@xyz.hi"
    assert_nil user.password

    assert user.authenticate("12341234")
  end
end
