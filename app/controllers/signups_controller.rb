class SignupsController < ApplicationController

  def new
    # @signup = Signup.new
    @user = User.new
    render
  end

  def create
    @user = User.new(user_params)
    @user.signup_date = Date.today 
    if @user.save
      # session[:screenname] = user.screenname
      # cookies[:remember_me] = user.screenname
      # redirect_to :signup_success
      redirect_to '/editions'
    else
      render :new
    end
  end

  # def create
  #   user = User.new(params.permit(:screenname, :password, :email))
  #   user.signup_date = Today.date
  #   if user.save
  #     session[:screenname] = user.screenname
  #     cookies[:remember_me] = user.screenname
  #
  #     redirect_to '/editions'
  #   else
  #     redirect_to '/'
  #   end
  # end


private

  def user_params
    params.require(:user).permit(:screenname, :password, :email)
  end

end
