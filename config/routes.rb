Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  mount_devise_token_auth_for 'User', at: 'auth'

  resources :organizations, only: nil do
    resources :clinics, only: :index
  end

  resources :clinics, only: nil do
    resources :staff, only: [:index, :show] do
      resources :qualification, only: [:create, :update] do 
        collection do
          get :show
        end
      end
    end
  end
  resources :roles, only: :index
end
