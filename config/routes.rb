require 'sidekiq/web'

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
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
    get '/clients/:client_id/meta_data', to: 'client_meta_data#selectable_options'
    get '/scheduling_meta_data', to: 'scheduling_meta_data#selectable_options'
    get '/clients/:client_id/service_providers_list', to: 'client_meta_data#service_providers_list'

    resources :schedulings do
      resources :soap_notes
    end
  end
end
