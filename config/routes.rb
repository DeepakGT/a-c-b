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
  end if Rails.env.staging? || Rails.env.production?

  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Sidekiq::Web => '/sidekiq'
  scope :api do
    # mount_devise_token_auth_for 'User', at: 'auth'
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      registrations: 'overrides/registrations'
    }

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
      get '/funding_sources_list', to: 'client_meta_data#funding_sources_list'
      get '/service_providers_list', to: 'client_meta_data#service_providers_list'
      get '/client_data', to: 'client_meta_data#client_data'
      get '/soap_notes', to: 'client_meta_data#soap_notes'
      get '/soap_notes/:id', to: 'client_meta_data#soap_note_detail'
      resources :service_addresses, controller: 'client_service_addresses'
      post '/create_office_address', to: 'client_service_addresses#create_office_address'
      post '/create_early_auths', to: 'client_enrollment_services#create_early_auths'
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
    get '/rbt_list',to: 'meta_data#rbt_list'
    get '/rbt_appointments', to: 'scheduling_meta_data#rbt_appointments'
    get '/bcba_appointments', to: 'scheduling_meta_data#bcba_appointments'
    get '/executive_director_appointments', to: 'scheduling_meta_data#executive_director_appointments'
    get '/catalyst/sync_data', to: 'catalyst#sync_data'
    put '/catalyst/update_appointment_units', to: 'catalyst#update_appointment_units'
    put '/catalyst/assign_catalyst_note', to: 'catalyst#assign_catalyst_note'
    put '/catalyst/delete_catalyst_soap_note', to: 'catalyst#delete_catalyst_soap_note'
    get '/catalyst/catalyst_data/:id', to: 'catalyst#catalyst_data_with_multiple_appointments'
    get '/catalyst/:catalyst_data_id/appointments_list', to: 'catalyst#appointments_list'
    get '/billing_dashboard', to: 'scheduling_meta_data#billing_dashboard'
    get '/sync_soap_notes', to: 'catalyst#sync_soap_notes'
    get '/unassigned_catalyst_soap_notes', to: 'scheduling_meta_data#unassigned_catalyst_soap_notes'
    get '/schedulings/clients_and_staff_list', to: 'scheduling_meta_data#clients_and_staff_list_for_filter'
    put '/schedulings/assign_multiple_soap_notes_of_same_location', to: 'catalyst#appointment_with_multiple_soap_notes'
    put '/schedulings/render_appointment', to: 'schedulings#render_appointment'
    get '/schedulings/split_appointment_detail/:id', to: 'schedulings#split_appointment_detail'
    post '/schedulings/create_split_appointment', to: 'schedulings#create_split_appointment'
    get '/catalyst/:catalyst_data_id/matching_appointments_list', to: 'catalyst#matching_appointments_list'
    resources :schedulings do
      post '/create_without_staff', to: 'schedulings#create_without_staff', on: :collection
      post '/create_without_client', to: 'schedulings#create_without_client', on: :collection
      put '/update_without_client/:id', to: 'schedulings#update_without_client', on: :collection
      resources :soap_notes
      resources :change_requests, controller: 'scheduling_change_requests', only: %i[create update]
    end

    get '/current_user_detail', to: 'users#current_user_detail'
    put '/update_default_schedule_view', to: 'users#update_default_schedule_view'

    get '/setting', to: 'settings#show'
    put '/setting', to: 'settings#update'
  end
end
