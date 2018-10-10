Rails.application.routes.draw do
  resources :forms
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
  get "status", to: "site#status", as: :status
  root to: "site#index"
end
