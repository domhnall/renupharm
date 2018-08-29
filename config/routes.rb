Rails.application.routes.draw do
  resource :pages, only: [:index], path: '/' do
    get :privacy_policy
  end

  resources :surveys, only: [:new, :create]

  root 'pages#index'
end
