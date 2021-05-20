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

  # describe "if the screenname or password are incorrect" do
  #   it "should clear the password, but remember the screenname" do
  test "it should clear password if password is incorrect" do
    #user = users(:bubblegum)
    user = User.create(
       screenname: "Marvel",
       password: "123456",
       email: "lalala@yaya.ca")

    #assert_false user.authenticate("dinosaur")
    # assert_not_password user, "dinosaur"

    post :create, params: { 
        screenname: user.screenname,
        password: "654321" } 

    assert_response :success
    assert_template :new
    assert_template layout: false 
    #assert_equal "Screenname or password incorrect.", flash[:notice]
    #assert_equal "Screenname and password didn't match.", flash[:notice]
    assert_equal "Screenname and password didn't match.", flash[:notice]

    # HaCk: Ensure notice set in flash.now by 
    #   sweeping flash and checking for nil
    @controller.flash.sweep
    assert_nil flash[:notice]

    #should set_flash.now[:notice].to("Screenname and password didn't match.")

    assert_equal user.screenname, @controller.user.screenname
    
    #assert_select "input[name=screenname]"
    assert_select "input[name=screenname][value=#{user.screenname}]"
    assert_select "input[type=password]"

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
