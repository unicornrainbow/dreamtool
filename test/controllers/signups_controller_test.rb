require 'test_helper'

class SignupsControllerTest < ActionController::TestCase


  test "signup creates new user" do

    assert_difference 'User.count' do
      post :create, params: {
        user: {
          screenname: "Jessica",
          email: "jbird@fiesta.net",
          password: "leprechaun" }}
     end

     user = User.last

     assert_equal "Jessica", user.screenname
     assert_equal "jbird@fiesta.net", user.email

     assert_nil user.password
     assert user.has_password?
     assert user.authenticate("leprechaun")

     assert_equal Date.today, user.signup_date 

  end

end
