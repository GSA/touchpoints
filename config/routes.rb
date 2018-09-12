Rails.application.routes.draw do
  resources :touchpoints
  devise_for :users
  get 'site/index'
  root to: "site#index"
end
