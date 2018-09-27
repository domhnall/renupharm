Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'account/edit', to: 'users/registrations#edit'
    put 'account', to: 'devise/registrations#update'
    patch 'account', to: 'devise/registrations#update'
    delete 'account', to: 'devise/registrations#destroy'
  end

  resource :pages, only: [:index], path: '/' do
    get :privacy_policy
    get :cookies_policy
  end

  resources :survey_responses, only: [:new, :create]
  resource :dashboard, only: [:show]

  namespace :sales do
    resources :contacts, only: [:create]
  end

  namespace :admin do
    namespace :sales do
      resources :pharmacies
      resources :contacts
    end
    resources :survey_responses, only: [:index]
    resources :users
  end

  root 'pages#index'
end
