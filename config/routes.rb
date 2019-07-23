Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

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
    resources :form_templates
    resources :forms
    resources :users, except: [:new]
    resources :organizations
    resources :pra_contacts
    resources :programs
    resources :services do
      member do
        post "add_user", to: "services#add_user", as: :add_user
        post "remove_user", to: "services#remove_user", as: :remove_user
      end
    end
    resources :touchpoints do
      member do
        get "export_submissions", to: "touchpoints#export_submissions", as: :export_submissions
        get "example", to: "touchpoints#example", as: :example
        get "js", to: "touchpoints#js", as: :js
        get "toggle_editability", to: "touchpoints#toggle_editability", as: :toggle_editability
        get "export_pra_document", as: :export_pra_document
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
  get "onboarding", to: "site#onboarding", as: :onboarding
  root to: "site#index"
end
