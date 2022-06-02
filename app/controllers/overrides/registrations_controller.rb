module Overrides
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    def resource_errors
      super[:full_messages]
    end
  end 
end
