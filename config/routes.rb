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

  resources :survey_responses, only: [:index, :new, :create]
  resource :dashboard, only: [:show]
  resource :profile, only: [:show, :edit, :update]

  namespace :sales do
    resources :contacts, only: [:create]
  end

  namespace :admin do
    namespace :sales do
      resources :pharmacies do
        resources :comments, only: [:create, :update, :destroy]
      end
      resources :contacts do
        resources :comments, only: [:create, :update, :destroy]
      end
    end
    resources :survey_responses, only: [:index]
    resources :users

    namespace :marketplace do
      resources :pharmacies, only: [:index, :new, :create, :show, :edit, :update]
      resources :orders, only: [:index, :edit, :update]
    end
  end

  root 'pages#index'
end
