Rails.application.routes.draw do
  devise_for :users, skip: :registrations
  devise_scope :user do
    get 'account/edit', to: 'users/registrations#edit'
    put 'account', to: 'users/registrations#update'
    patch 'account', to: 'users/registrations#update'
    delete 'account', to: 'users/registrations#destroy'
  end

  resource :pages, only: [:index], path: '/' do
    get :privacy_policy
    get :cookies_policy
    get :terms_and_conditions
  end

  resources :survey_responses, only: [:index, :new, :create]
  resource :dashboard, only: [:show]
  resource :profile, only: [:show, :edit, :update] do
    get :accept_terms_and_conditions
  end
  resolve('Profile'){ [:profile] }

  resource :notification_config, only: [:show, :update]
  resource :web_push_subscriptions, only: [:create]

  namespace :sales do
    resources :contacts, only: [:create]
  end

  namespace :marketplace do
    root to: "listings#index"
    resource :cart, only: [:show, :update]
    resources :orders, only: [:show] do
      member do
        get :receipt
      end
    end
    resources :products, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :listings, only: [:show, :destroy]

    resources :pharmacies, only: [] do
      get '/:section',
        to: 'pharmacies#show',
        as: :profile,
        constraints: { section: /(profile|listings|agents|pharmacy_products|credit_cards|bank_account)/ }
      resources :credit_cards, only: [:update]
      resources :products, only: [:index, :show, :new, :create, :edit, :update]
      resources :listings, only: [:index, :new, :create, :edit, :update, :destroy]
      resources :purchases, only: [:index, :show]
      resources :sales, only: [:index, :show]
      resource :bank_account, only: [:new, :create, :edit, :update]
      resources :agents, only: [:new, :create, :edit, :update]
    end
  end

  namespace :admin do
    namespace :sales do
      resources :pharmacies do
        resources :comments, only: [:create, :update, :destroy], controller: 'pharmacy_comments'
      end
      resources :contacts do
        resources :comments, only: [:create, :update, :destroy], controller: 'contact_comments'
      end
    end
    resources :survey_responses, only: [:index]
    resources :users, only: [:index, :show, :edit, :update, :destroy]

    namespace :marketplace do
      resources :pharmacies, only: [:index, :new, :create, :show, :edit, :update]
      resources :orders, only: [:index, :show, :edit, :update] do
        resources :comments, only: [:create, :update, :destroy], controller: 'order_comments'
      end
    end
  end

  root 'pages#index'
end
