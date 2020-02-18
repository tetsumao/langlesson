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
    get 'by_category_detail/:year/:month/:day' => :by_category_detail, as: :by_category_detail, constraints: ->(request) {
      Date.valid_date?(request.params[:year].to_i, request.params[:month].to_i, request.params[:day].to_i)
    }
  end
  resources :categories, except: [:show]
  resources :periods, except: [:show]
  root 'home#index'
end
