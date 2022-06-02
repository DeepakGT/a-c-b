class Overrides < DeviseTokenAuth::RegistrationsController
  class RegistrationsController
    def resource_errors
      super[:full_messages]
    end
  end 
end
