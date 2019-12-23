require 'sidekiq/web'


Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  mount Sidekiq::Web => '/sidekiq'

  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :touchpoints, only: [:show] do
    member do
      get "js", to: "touchpoints#js", as: :js
      get "submit", to: "submissions#new", touchpoint: true, as: :submit
    end
    resources :forms
    resources :submissions, only: [:new, :create] do
    end
  end

  namespace :admin do
    resources :forms do
      resources :form_sections
      resources :questions do
        resources :question_options
      end
      member do
        post "copy", to: "forms#copy", as: :copy
      end
    end
    resources :users, except: [:new] do
      member do
        get "deactivate", to: "users#deactivate"
      end
    end
    resources :organizations
    resources :touchpoints do
      member do
        get "export_submissions", to: "touchpoints#export_submissions", as: :export_submissions
        get "export_a11_header", to: "touchpoints#export_a11_header", as: :export_a11_header
        get "export_a11_submissions", to: "touchpoints#export_a11_submissions", as: :export_a11_submissions
        get "example", to: "touchpoints#example", as: :example
        get "js", to: "touchpoints#js", as: :js
        get "export_pra_document", as: :export_pra_document

        post "add_user", to: "touchpoints#add_user", as: :add_user
        delete "remove_user", to: "touchpoints#remove_user", as: :remove_user
      end
      resources :forms
      resources :submissions, only: [:new, :show, :create, :destroy] do
        member do
          post "flag", to: "submissions#flag", as: :flag
        end
      end
    end
    root to: "site#index"
  end



  get "status", to: "site#status", as: :status
  root to: "site#index"
end
