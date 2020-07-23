class SignupsController < ApplicationController

  def new
    render layout: false
  end

  def create
    user = User.new(params.permit(:screenname, :password, :email))
    user.signup_date = Today.date
    if user.save
      session[:screenname] = user.screenname
      cookies[:remember_me] = user.screenname

      redirect_to '/editions'
    else
      redirect_to '/'
    end
  end

end
