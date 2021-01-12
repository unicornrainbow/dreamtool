class HomeController < ApplicationController #ActionController::Base

  skip_before_action :verify_authenticity_token, only: [:hot_muffins]

  def index
    if signed_in?
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
    session[:screenname] = params[:screenname]
    redirect_to '/'
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
