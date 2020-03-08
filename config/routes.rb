Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }
  resources :users, only: [:show]
  resources :tickets, only: [:index, :new, :create]
  resources :teachers do
    member do
      post :proxy_sign_in
    end
    resources :lessons do
      member do
        get :edit_report
        patch :update_report
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
  namespace :visualizations do
    get :by_date
    get :by_teacher
    get :by_teacher_detail
    get :by_category
    get :by_category_detail
  end
  namespace :payments do
    get :card
    post :register_card
    delete :delete_card
    post :subscription
    get :history
  end
  resources :categories, except: [:show]
  resources :periods, except: [:show]
  root 'home#index'
end
