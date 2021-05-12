require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # @session = sessions(:one)
  end

  test "should create session" do 
    user = User.create(
       screenname: "Marvel",
       password: "123456",
       email: "lalala@yaya.ca")

    post sessions_url, params: { 
        screenname: "Marvel",
        password: "123456" } 

     # We should have something in the session.
     assert_equal user.id, session["user_id"] 
     assert_equal user.screenname, session['screenname']
  end

  test "should destroy session" do
    user = users(:one)
    sign_in_as(user)
     
    assert_equal user.id, session["user_id"] 
    assert_equal user.screenname, session['screenname']
    

    session['screenname'] = 'value'
    session['user_id'] = 'value'
    delete session_url(@session)

    assert_equal nil, session['user_id']
    assert_equal nil, session['screenname']

    #assert_redirected_to sessions_url
  end
end
