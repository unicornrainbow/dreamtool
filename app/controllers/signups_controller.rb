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
      session[:screenname] = @user.screenname
      session[:user_id] = @user.id
      # cookies[:remember_me] = user.screenname
      # redirect_to :signup_success
      redirect_to '/editions'
    else
      flash.now[:alert] = @user.errors.full_messages.first + "."
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
    params.require(:user).permit(:first_name, :last_name,
      :screenname, :email, :password, :password_confirmation,
      :prefix, :suffix)
  end

end
