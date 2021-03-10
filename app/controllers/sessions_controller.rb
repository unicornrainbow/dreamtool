

class SessionsController  <  ApplicationController
  def new; end
end

  __END__
def         create
      user = User.find_by(screenname: params[:screenname])
        if user && user.authenticate(params[:password])
          session[:user_id] = user.id
          redirect_to root_url, notice: "Signed in that is!"
        else
          flash.now.alert = "Screenname or password is invalid."
        end
end

def create
    if params[:screenname].empty?
        redirect_to '/' and return
    end

      screenname = params[:screenname] #.downcase

      user = User.find_by(screenname: screenname)

      # If no user,
      # look user up by email using screenname.
      unless user
        user = User.find_by(email: screenname)
      end

      unless user
        user = User.create(screenname: params[:screenname],
          password: params[:password])
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
          redirect_back # Retry
        end
      else
        session[:screenname] = user.screenname
        cookies[:remember_me] = user.screenname
        redirect_to root_url
      end

    rescue Mongoid::Errors::DocumentNotFound
        redirect_to '/' # Retry
    end

    def new
      user =  User.find_by params.slice(:screenname, :email)

      if user

      end


      unless user
        user = User.create(screenname: params[:screenname],
          password: params[:password])
      end

      if user.has_password?
        if user.valid_password?(params[:password])
          session[:screenname] = user.screenname
          cookies[:remember_me] = user.screenname

          redirect_to '/editions'
        else
          redirect_back # Retry
        end
      else
        session[:screenname] = user.screenname
        cookies[:remember_me] = user.screenname
        redirect_to root_url
      end

    end

    def destroy
      session.delete :screenname
      redirect_to '/'
    end

end

         # class SessionsController <
         #     Devise::SessionsController
         #        end
