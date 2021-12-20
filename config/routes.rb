Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  mount_devise_token_auth_for 'User', at: 'auth'

  resources :organizations, only: nil do
    resources :clinics, only: :index
  end

  resources :clinics, only: nil do
    resources :staff, only: %i[index show update] do
      get :supervisor_list, on: :collection
    end
    resources :funding_sources, only: %i[index create update]
  end
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
