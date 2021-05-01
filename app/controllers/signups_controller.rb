class SignupsController < ApplicationController

  def new
    # @signup = Signup.new
    @user = User.new
    render
  end

  # delete me
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

  def create
    @user = User.create(user_params)
    unless @user.errors
      redirect_to :signup_success
    else
      render :new
    end

  end

private

  def user_params
    params.require(:user).permit(:screenname)
  end

end
