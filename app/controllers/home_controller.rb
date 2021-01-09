class HomeController < ApplicationController #ActionController::Base

  skip_before_action :verify_authenticity_token, only: [:hot_muffins]

  def index
    unless signed_in?
      render 'landing', layout: false
    else
      render 'index'
    end
  end

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

    # cookies.delete! "_press_session"
    # session.destroy

     # { screenname: 'Princess Pink' }
    # [:screenname] =
    @remember_me = cookies[:remember_me]

    # render layout: false
    render "landing", layout: false
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
  
  def sign_in
    session[:screenname] = params[:screenname]
    redirect_to '/editions'
  end

  def sign_out
    if request.method == 'POST'
      session.delete :screenname
      redirect_to '/' and return
    end

    if session[:screenname]
      render layout: false
    else
      redirect_to root_path
    end
  end

  # def sign_out
  #   session.delete :screenname
  #   redirect_to '/'
  # end

end
