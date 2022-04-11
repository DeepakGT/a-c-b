require 'sidekiq/web'
require 'sidekiq/cron/web' 

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

    resources :organizations
    
    resources :clinics do
      resources :funding_sources
    end
    resources :staff do
      resources :staff_credentials, controller: 'staff_qualifications'
      resources :staff_clinics
    end

    resources :clients do
      resources :client_enrollments
      resources :client_enrollment_services, only: %i[create update show destroy]
      resources :contacts
      resources :notes, controller: 'client_notes'
      resources :attachments, controller: 'client_attachments'
      get '/meta_data', to: 'client_meta_data#selectable_options'
      get '/service_providers_list', to: 'client_meta_data#service_providers_list'
      get '/client_data', to: 'client_meta_data#client_data'
      resources :service_addresses, controller: 'client_service_addresses'
    end
    
    resources :credentials, controller: 'qualifications' do
      get :types, on: :collection
    end

    resources :services

    resources :roles 

    get 'meta_data/selectable_options'
    get '/supervisor_list', to: 'staff#supervisor_list'
    get '/addresses/country_list', to: 'addresses#country_list'
    get '/roles_list', to: 'roles#roles_list'
    get '/phone_types', to: 'staff#phone_types'
    get '/scheduling_meta_data', to: 'scheduling_meta_data#selectable_options'
    get '/services_list', to: 'scheduling_meta_data#services_list'
    get '/clients_list', to: 'staff_meta_data#clients_list'
    get '/clinics_list',to: 'meta_data#clinics_list'
    get '/bcba_list',to: 'meta_data#bcba_list'
    get '/rbt_appointments', to: 'scheduling_meta_data#rbt_appointments'
    get '/bcba_appointments', to: 'scheduling_meta_data#bcba_appointments'
    get '/executive_director_appointments', to: 'scheduling_meta_data#executive_director_appointments'
    get '/catalyst_sync', to: 'catalyst#sync_with_catalyst'

    resources :schedulings do
      resources :soap_notes
      resources :change_requests, controller: 'scheduling_change_requests', only: %i[create update]
    end
  end
end
