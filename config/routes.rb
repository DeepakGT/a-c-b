Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  mount_devise_token_auth_for 'User', at: 'auth'

  resources :organizations, only: nil do
    resources :clinics, only: :index
  end

  resources :clinics, only: nil do
    resources :staff, only: %i[index show update]
  end
  resources :roles, only: :index
  resources :credentials, only: %i[index show create update]

  resources :staff, only: nil do
    resources :qualifications, only: %i[create update]
  end
  get '/staff/:staff_id/qualification', to: 'qualifications#show'

  resources :services, only: %i[index create update]
end
