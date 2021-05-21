require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "should create session" do
    get :index

    assert_template :landing
    assert_template layout: :welcome
  end

end
