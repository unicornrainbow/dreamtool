class HomeController < ApplicationController #ActionController::Base

  skip_before_action :verify_authenticity_token, only: [:hot_muffins]

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

    # cookies.delete! "_press_session"
    # session.destroy

     # { screenname: 'Princess Pink' }
    # [:screenname] =
    @remember_me = cookies[:remember_me]

    render layout: false
  end

  def index
    unless signed_in?
      render 'landing', layout: false
    else
      render 'index'
    end
  end

  # def sign_in
  #   if params[:screenname].empty?
  #       redirect_to '/editions' and return
  #   end
  #
  #   gibberish = params[:screenname] #.downcase
  #
  #   #user = User.find_by({screenname})
  #   user = User.find_by(screenname: gibberish)
  #
  #   unless user
  #     user = User.find_by(email: gibberish)
  #   end
  #
  #   unless user
  #     user = User.create(screenname: params[:screenname],
  #       password: params[:password])
  #   end
  #
  #   # user = User.first(conditions: { screenname: /^#{screenname}$/i })
  #   # user = User.find_by(screenname: screenname, 'i')
  #   # user  = User.where(screenname: /^#{screenname}$/i).first
  #
  #
  #   if user.has_password?
  #     if user.valid_password?(params[:password])
  #       session[:screenname] = user.screenname
  #       cookies[:remember_me] = user.screenname
  #
  #       redirect_to '/editions'
  #     else
  #       redirect_to '/' # Retry
  #     end
  #   else
  #     session[:screenname] = user.screenname
  #     cookies[:remember_me] = user.screenname
  #     redirect_to '/editions'
  #   end
  #
  # rescue Mongoid::Errors::DocumentNotFound
  #     redirect_to '/' # Retry
  # end
  #
  # def sign_out
  #   session.delete :screenname
  #   redirect_to '/'
  # end

end
