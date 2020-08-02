class Users::SessionsController < Devise::SessionsController
  # GET /resource/sign_in
  # def new
  #   super
  #   # render layout: false
  # end

  # def new
  #   self.resource = resource_class.new(sign_in_params)
  #   clean_up_passwords(resource)
  #   yield resource if block_given?
  #   respond_with(resource, serialize_options(resource))
  # end

  def new
    request.env["devise.mapping"] = Devise.mappings[:user]
    super
  end

  def create

  end
end
