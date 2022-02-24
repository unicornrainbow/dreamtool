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

    if screenname.empty?
      # flash.notice = "Please provide your screenname"
      # redirect_to "/" and return
      flash.now.notice = "Please provide your screenname"
      render :new, layout: 'welcome'
      return
    end

    @user = User.find_by(screenname: screenname)

    unless @user
      @user = User.find_by(email: screenname)
    end

    if @user
      unless @user.has_password?
        if params[:password].presence
          flash.now.notice = "Screenname and password didn't match."
          render :new, layout: 'welcome'
          return
        end

        session[:user_id] = @user.id
        session[:screenname] = @user.screenname
        redirect_to root_url, notice: "Signed in!"
        return
      else
        if @user.authenticate(params[:password])
          session[:user_id] = @user.id
          session[:screenname] = @user.screenname
          redirect_to root_url, notice: "Signed in!"
        else
          flash.now.notice = "Screenname and password didn't match."
          render :new, layout: 'welcome'
        end
      end
    else
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
