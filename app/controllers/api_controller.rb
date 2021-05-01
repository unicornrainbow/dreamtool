class ApiController <  ActionController::Base
  before_action :authenticate_user!
  respond_to :json
end
