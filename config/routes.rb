Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  resources :users, only: [:show] do
    resources :tickets, only: [:index, :new, :create]
  end
  resources :teachers do
    member do
      post :proxy_sign_in
    end
    resources :lessons do
      member do
        post :reserve
      end
      collection do
        get :history
      end
    end
  end
  namespace :lessons do
    get :search
    get :reserved
  end
  resources :categories, except: [:show]
  resources :periods, except: [:show]
  root 'home#index'
end
