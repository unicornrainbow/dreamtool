require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  test "current_user" do
    user = users(:bubblegum)
    session[:user_id] = user.id
    assert_equal user.id, @controller.send(:current_user).id
  end

end
