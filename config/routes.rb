Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  scope :api do
    mount_devise_token_auth_for 'User', at: 'auth'

    resources :organizations, only: %i[create update show index] 
    
    resources :clinics, only: %i[index create show update] do
      resources :staff, only: %i[] do
        get :supervisor_list, on: :collection
      end
      resources :funding_sources, only: %i[index create update show]
    end

    resources :staff do
      resources :staff_credentials
      resources :staff_clinics
    end

    resources :clients, only: %i[index create update show] do
      resources :client_enrollments
      resources :client_enrollment_services
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
    get '/addresses/country_list', to: 'addresses#country_list'
    get '/roles_list', to: 'roles#roles_list'
    get '/phone_types', to: 'staff#phone_types'
  end
end
