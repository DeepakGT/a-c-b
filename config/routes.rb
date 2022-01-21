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
  end
  get :payer_statuses, to: 'clients#payer_statuses'
  get :preferred_languages, to: 'clients#preferred_languages'
  get :dq_reasons, to: 'clients#dq_reasons'

  get 'addresses/country_list', to: 'addresses#country_list'
  
  get :phone_types, to: 'staff#phone_types'
  resources :roles, only: :index
  resources :credentials, only: %i[index show create update] do
    get :types, on: :collection
  end

  resources :staff, only: nil do
    resources :staff_credentials
  end
  get '/staff/:staff_id/qualification', to: 'qualifications#show'

  resources :services, only: %i[index create update show]
end
