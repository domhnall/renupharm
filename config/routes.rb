Rails.application.routes.draw do
  resources :pages, only: [:index]

  resources :surveys, only: [:new, :create]

  root 'pages#index'
end
