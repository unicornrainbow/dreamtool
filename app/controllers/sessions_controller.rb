class SessionsController < ApplicationController

  attr_reader :user
  helper_method :user

  layout 'welcome'

  def show
    if current_user
      redirect_to :root
    else
      redirect_to :new_session
    end
  end

  def create
    screenname = params[:screenname]

    @user = User.find_by(screenname: screenname)

    unless @user
      @user = User.find_by(email: screenname)
    end

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      session[:screenname] = @user.screenname
      redirect_to root_url, notice: "Signed in!"
    else
      #flash.now.alert = "Email or password is invalid."
      #flash.notice = "Screenname or password incorrect."
      #flash.notice = "The screenname or even perhaps the \
      #          password you provided was so incorrect."
      #flash.notice = "The screenname and password provided did not match."
      #flash.notice = "Screenname and password didn't match."
      flash.now.notice = "Screenname and password didn't match."
      render :new, layout: 'welcome'
    end
  end


  def sign_in
    if params[:screenname].empty?
        redirect_to '/editions' and return
    end

    gibberish = params[:screenname] #.downcase

    #user = user.find_by({screenname})
    user = user.find_by(screenname: gibberish)

    unless user
      user = user.find_by(email: gibberish)
    end

    unless user
      user = user.create(screenname: params[:screenname],
        password: params[:password])
    end

    # user = user.first(conditions: { screenname: /^#{screenname}$/i })
    # user = user.find_by(screenname: screenname, 'i')
    # user  = user.where(screenname: /^#{screenname}$/i).first


    if user.has_password?
      if user.valid_password?(params[:password])
        session[:screenname] = user.screenname
        cookies[:remember_me] = user.screenname

        redirect_to '/editions'
      else
        redirect_to '/' # retry
      end
    else
      session[:screenname] = user.screenname
      cookies[:remember_me] = user.screenname
      redirect_to '/editions'
    end

  rescue mongoid::errors::documentnotfound
      redirect_to '/' # retry
  end

  def destroy
    session.delete(:screenname)
    session.delete(:user_id)
    redirect_to :root
  end

end
