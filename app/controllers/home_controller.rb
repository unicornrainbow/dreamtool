class HomeController < ApplicationController #ActionController::Base

  skip_before_filter :verify_authenticity_token, only: [:hot_muffins]

  def index
    if session[:screenname]
      redirect_to '/editions' and return
    end

    @remember_me = cookies[:remember_me]
    render layout: false
  end

  def sign_in
    #if params[:screenname].empty?
    #  redirect_to '/editions' and return
    #end

    screenname = params[:screenname] #.downcase

    #user = User.find_by({screenname})
    user = User.find_by(screenname: screenname)
    
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
      User.create(params.permit(:screenname, :password))
      redirect_to '/'
    end
  end


end
