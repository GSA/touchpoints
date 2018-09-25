Rails.application.routes.draw do
  resources :submissions, except: [:new]
  resources :touchpoints
  devise_for :users
  namespace :admin do
    resources :users
    resources :organizations
    root to: "site#index"
  end
  get "example", to: "site#example", as: :example
  root to: "site#index"
end
