Rails.application.routes.draw do
  resources :touchpoints
  devise_for :users
  get "example", to: "site#example", as: :example
  root to: "site#index"
end
