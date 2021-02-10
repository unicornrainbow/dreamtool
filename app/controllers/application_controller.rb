require 'extensions/date'

class ApplicationController < ActionController::Base

  before_action :set_locale

  helper_method :screenname,
    :signed_in?


 def set_locale
   [params[:locale], cookies[:locale], extract_locale, I18n.default_locale].each do |l|
     if l && I18n.available_locales.index(l.to_sym)
       I18n.locale = l
       break
     end
   end
   cookies[:locale] = params[:locale] if params[:locale]
 end

 def extract_locale
   request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first if request.env['HTTP_ACCEPT_LANGUAGE']
 end

  before_action do
    # Redirect .herokuapp.com to .tk
    if request.domain == "dreamtool.herokuapp.com"
      redirect_to request.original_url.sub(".herokuapp.com", ".tk")
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :track_hit

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def not_authorized
    render "403", status: 403
  end

  def routing_error
    render "404", status: 404
  end

  def logo
    render layout: false
  end

  def track_hit
    # request[]
    # render text: request.ip + request.fullpath
    Hit.create(
      ip: request.ip,
      url: request.original_url,
      date: Today.date
    )
    # $redis.incr "Hits: #{today}"
    # Visit.create ip: ip, url: url
  end

  # Returns today's date as an mdy string.
  def today
    Date.today % '%m/%d/%Y'
  end

protected

  def screenname
    # @screenname ||= session[:screenname]
    @screenname ||= cookies[:screenname]
  end

  def current_user
    if @current_user
      @current_user
    else
      if screenname
        @current_user = User.find_by(screenname: screenname)
      end
    end
  end

  def signed_in?
    if screenname
      !screenname.empty?
    end
  end

  def force_trailing_slash
    redirect_to request.original_url + '/' unless request.original_url.match(/\/$/)
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def find_edition

    if params[:id].length == 24
      @edition = Edition.find(params[:id])
    else
      query = current_user.try(:editions) || Edition
      @edition = query.find_by(slug: params[:id])
    end
  end

end
