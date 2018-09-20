Rails.application.routes.draw do
  resources :touchpoints
  devise_for :users
  namespace :admin do
    resources :users
  end
  get "example", to: "site#example", as: :example
  root to: "site#index"
end
