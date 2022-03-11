require 'sidekiq/web'

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Rails.application.credentials.dig(:sidekiq, :user_name))) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Rails.application.credentials.dig(:sidekiq, :password)))
  end if Rails.env.staging?

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  scope :api do
    mount_devise_token_auth_for 'User', at: 'auth'

    resources :organizations, only: %i[create update show index] 
    
    resources :clinics, only: %i[index create show update] do
      resources :funding_sources, only: %i[index create update show]
    end
    resources :staff do
      resources :staff_credentials
      resources :staff_clinics
    end

    resources :clients, only: %i[index create update show] do
      resources :client_enrollments
      resources :client_enrollment_services, only: %i[create update show destroy]
      resources :contacts
      resources :notes, controller: 'client_notes'
      resources :attachments, controller: 'client_attachments'
    end
    
    resources :credentials, only: %i[index show create update] do
      get :types, on: :collection
    end

    resources :services, only: %i[index create update show]

    resources :roles, only: %i[index create update show] 

    get 'meta_data/selectable_options'
    get '/supervisor_list', to: 'staff#supervisor_list'
    get '/addresses/country_list', to: 'addresses#country_list'
    get '/roles_list', to: 'roles#roles_list'
    get '/phone_types', to: 'staff#phone_types'
    get '/clients/:client_id/meta_data', to: 'client_meta_data#selectable_options'
    get '/scheduling_meta_data', to: 'scheduling_meta_data#selectable_options'

    resources :schedulings do
      resources :soap_notes
    end
  end
end
