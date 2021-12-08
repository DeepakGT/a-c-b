RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
end

def set_auth_headers(auth_headers)
  request.headers['Uid'] = auth_headers['uid']
  request.headers['Access-Token'] = auth_headers['access-token']
  request.headers['Client'] = auth_headers['client']
end
