Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'account/edit', to: 'devise/registrations#edit'
    put 'account', to: 'devise/registrations#update'
    patch 'account', to: 'devise/registrations#update'
    delete 'account', to: 'devise/registrations#destroy'
  end

  resource :pages, only: [:index], path: '/' do
    get :privacy_policy
  end

  resources :survey_responses, only: [:new, :create]
  resource :dashboard, only: [:show]

  namespace :sales do
    resources :contacts, only: [:create]
  end

  root 'pages#index'
end
