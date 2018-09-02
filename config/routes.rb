Rails.application.routes.draw do
  resource :pages, only: [:index], path: '/' do
    get :privacy_policy
  end

  resources :survey_responses, only: [:new, :create]

  root 'pages#index'
end
