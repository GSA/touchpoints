Rails.application.routes.draw do
  devise_for :users

  resources :touchpoints, only: [:index, :show] do
    member do
      get "submit", to: "submissions#new", touchpoint: true, as: :submit
      get "js", to: "touchpoints#js", as: :js
    end
    resources :forms
    resources :submissions, only: [:new, :create, :show] do
    end
  end

  namespace :admin do
    resources :containers
    resources :forms
    resources :users
    resources :organizations
    resources :submissions, except: [:new, :index, :create]
    resources :triggers
    resources :touchpoints do
      member do
        get "example", to: "touchpoints#example", as: :example
        get "example/gtm", to: "touchpoints#gtm_example", as: :gtm_example
      end
      resources :forms
      resources :submissions, only: [:new, :show, :create]
    end
    root to: "site#index"
  end

  get "status", to: "site#status", as: :status
  get "onboarding", to: "site#onboarding", as: :onboarding
  root to: "site#index"
end
