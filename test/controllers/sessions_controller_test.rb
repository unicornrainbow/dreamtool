require 'test_helper'

#class SessionsControllerTest < ActionDispatch::IntegrationTest
class SessionsControllerTest < ActionController::TestCase

  setup do
    @user = users(:candi)
  end

  test "should create session" do 
    user = User.create(
       screenname: "Marvel",
       password: "123456",
       email: "lalala@yaya.ca")

    #post sessions_url, params: { 
    post :create, params: { 
        screenname: "Marvel",
        password: "123456" } 

     # We should have something in the session.
     assert_equal user.id, session["user_id"] 
     assert_equal user.screenname, session['screenname']
  end

  test "should destroy session" do
    user = users(:candi)
    #sign_in_as(user)
     
     
    session["user_id"] = user.id
    assert_equal user.id, session["user_id"] 
    session['screenname'] = user.screenname
    assert_equal user.screenname, session['screenname']
    

    session['screenname'] = 'value'
    session['user_id'] = 'value'
    #delete session_url(@session)
    delete :destroy

    assert_nil session['user_id']
    assert_nil session['screenname']

    assert_redirected_to root_url
  end

end
