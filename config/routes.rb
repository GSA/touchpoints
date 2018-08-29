Rails.application.routes.draw do
  devise_for :users
  get 'site/index'
  root to: "site#index"
end
