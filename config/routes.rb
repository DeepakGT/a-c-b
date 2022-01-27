Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  mount_devise_token_auth_for 'User', at: 'auth'

  resources :organizations, only: %i[create update show index] 
  
  resources :clinics, only: %i[index create show update] do
    resources :staff, only: %i[] do
      get :supervisor_list, on: :collection
    end
    resources :funding_sources, only: %i[index create update show]
  end

  resources :staff, only: %i[index show update create]
  resources :clients, only: %i[index create update show] do
    resources :client_enrollments, only: %i[create show index update destroy]
    resources :contacts, only: %i[index create show update destroy]
  end
  
  resources :credentials, only: %i[index show create update] do
    get :types, on: :collection
  end

  resources :staff, only: nil do
    resources :staff_credentials
  end

  resources :services, only: %i[index create update show]

  get 'meta_data/selectable_options'
  get '/addresses/country_list', to: 'addresses#country_list'
  resources :roles, only: :index
  get '/phone_types', to: 'staff#phone_types'
end
