Rails.application.routes.draw do
  resources :submissions, except: [:new, :index, :create]
  resources :touchpoints do
    resources :submissions, only: [:new, :show, :index, :create]
  end
  devise_for :users
  namespace :admin do
    resources :users
    resources :organizations
    root to: "site#index"
  end
  get "example", to: "site#example", as: :example
  root to: "site#index"
end
