class HomeController < ApplicationController #ActionController::Base

  skip_before_action :verify_authenticity_token, only: [:hot_muffins]

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

     # { screenname: 'Princess Pink' }
    # [:screenname] =
    @remember_me = cookies[:remember_me]

    render layout: false
  end

  def sign_in
    if params[:screenname].empty?
        redirect_to '/editions' and return
    end

    gibberish = params[:screenname] #.downcase

    #user = User.find_by({screenname})
    user = User.find_by(screenname: gibberish)

    unless user
      user = User.find_by(email: gibberish)
    end

    # user = User.first(conditions: { screenname: /^#{screenname}$/i })
    # user = User.find_by(screenname: screenname, 'i')
    # user  = User.where(screenname: /^#{screenname}$/i).first


    if user.has_password?
      if user.valid_password?(params[:password])
        session[:screenname] = user.screenname
        cookies[:remember_me] = user.screenname

        redirect_to '/editions'
      else
        redirect_to '/' # Retry
      end
    else
      session[:screenname] = user.screenname
      cookies[:remember_me] = user.screenname
      redirect_to '/editions'
    end

  rescue Mongoid::Errors::DocumentNotFound
      redirect_to '/' # Retry
  end

  def sign_out
    session.delete :screenname
    redirect_to '/'
  end


  def hot_muffins
    if request.post?
      user = User.new(params.permit(:screenname, :password, :email))
      user.signup_date = Today.date
      if user.save
        session[:screenname] = user.screenname
        cookies[:remember_me] = user.screenname

        redirect_to '/editions'
      else
        redirect_to '/'
      end
    else
      render layout: false
    end
  end

end
