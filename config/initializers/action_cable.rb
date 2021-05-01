if Rails.env.development?
  Rails.application.config.action_cable.allowed_request_origins =  ['http://localhost:4321', 'http://127.0.0.1:4321']
end
