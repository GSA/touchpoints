require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  unless Rails.env.development?
    match "/404", :to => "errors#not_found", :via => :all
    match "/500", :to => "errors#internal_server_error", :via => :all
  end

  resources :forms, only: [:show] do
    member do
      get "js", to: "touchpoints#js", as: :js_form
      get "submit", to: "submissions#new", form: true, as: :submit
    end
    resources :submissions, only: [:new, :create]
  end

  resources :touchpoints, only: [:show] do
    member do
      get "js", to: "touchpoints#js", as: :js
      get "submit", to: "submissions#new", form: true, as: :submit
    end
    resources :submissions, only: [:new, :create]
  end

  namespace :api do
    namespace :v0 do
      resources :forms, only: [:index, :show]
    end
    namespace :v1 do
      resources :forms, only: [:index, :show]
    end
  end

  namespace :admin do
    get "/reporting/hisps", to: "reporting#hisps", as: :hisps
    get "/reporting/lifespan", to: "reporting#lifespan", as: :lifespan

    get "a11", to: "site#a11", as: :a11
    resources :service_providers
    resources :services do
      member do
        get "equity-assessment", to: "services#equity_assessment", as: :equity_assessment
        get "cx-reporting", to: "services#omb_cx_reporting", as: :omb_cx_reporting
      end
      resources :service_stages
    end

    resources :collections do
      member do
        post "copy", to: "collections#copy", as: :copy
        post "submit", to: "collections#submit", as: :submit
        post "publish", to: "collections#publish", as: :publish
        get "events", to: "collections#events", as: :events
      end
    end
    resources :omb_cx_reporting_collections
    resources :goals
    resources :milestones

    resources :websites do
      collection do
        get "search", to: "websites#search"
        get "gsa", to: "websites#gsa"
        get "export_csv", to: "websites#export_csv", as: :export_csv
        get "collection_preview", to: "websites@collection_preview", as: :collection_preview
      end
      member do
        get "costs", to: "websites#costs", as: :costs
        get "statuscard", to: "websites#statuscard", as: :statuscard
        get "collection_request", to: "websites@collection_request", as: :collection_request
        post "approve", to: "websites#approve", as: :approve
        post "deny", to: "websites#deny", as: :deny
        get "events", to: "websites#events", as: :events
      end
    end

    resources :forms do
      member do
        get "notifications", to: "forms#notifications", as: :notifications
        get "example", to: "forms#example", as: :example
        get "export", to: "forms#export", as: :export
        get "export_pra_document", as: :export_pra_document
        get "export_submissions", to: "forms#export_submissions", as: :export_submissions
        get "export_a11_header", to: "forms#export_a11_header", as: :export_a11_header
        get "export_a11_submissions", to: "forms#export_a11_submissions", as: :export_a11_submissions
        patch "invite", to: "forms#invite", as: :invite
        get "js", to: "forms#js", as: :js
        get "permissions", to: "forms#permissions", as: :permissions
        get "compliance", to: "forms#compliance", as: :compliance
        get "questions", to: "forms#questions", as: :questions
        get "responses", to: "forms#responses", as: :responses
        get "delivery_method", to: "forms#delivery_method", as: :delivery_method
        post "add_user", to: "forms#add_user", as: :add_user
        post "copy", to: "forms#copy", as: :copy
        post "publish", to: "forms#publish", as: :publish
        post "archive", to: "forms#archive", as: :archive
        delete "remove_user", to: "forms#remove_user", as: :remove_user
        patch "update_title", to: "forms#update_title", as: :update_title
        patch "update_instructions", to: "forms#update_instructions", as: :update_instructions
        patch "update_disclaimer_text", to: "forms#update_disclaimer_text", as: :update_disclaimer_text
        patch "update_success_text", to: "forms#update_success_text", as: :update_success_text
        patch "update_ui_truncation", to: "forms#update_ui_truncation", as: :update_ui_truncation
        patch "update_display_logo", to: "forms#update_display_logo", as: :update_display_logo
        patch "update_admin_options", to: "forms#update_admin_options", as: :update_admin_options
        patch "update_form_manager_options", to: "forms#update_form_manager_options", as: :update_form_manager_options
        get "events", to: "forms#events", as: :events
      end
      collection do
        post "copy", to: "forms#copy", as: :copy_id
      end
      resources :form_sections, except: [:index, :show, :edit] do
        patch "sort", to: "form_sections#sort", as: :sort_sections
        patch "update_title", to: "form_sections#update_title", as: :inline_update
      end
      resources :questions do
        member do
          patch "question_options", to: "question_options#sort", as: :sort_question_options
        end
        resources :question_options, except: [:index, :show] do
          patch "update_title", to: "question_options#update_title", as: :inline_update
        end
        collection do
          patch "sort", to: "questions#sort", as: :sort_questions
        end
      end
      resources :submissions, only: [:show, :update, :destroy] do
        member do
          post "flag", to: "submissions#flag", as: :flag
          post "unflag", to: "submissions#unflag", as: :unflag
          post "archive", to: "submissions#archive", as: :archive
          post "unarchive", to: "submissions#unarchive", as: :unarchive
        end
      end
    end
    resources :users, except: [:new] do
      collection do
        get "inactive", to: "users#inactive"
        get "deactivate", to: "users#deactivate"
        get "active", to: "users#active", as: :active
      end
    end
    resources :organizations
    resources :service_stages
    resources :barriers
    resources :service_stage_barriers

    get "dashboard", to: "site#index", as: :dashboard
    get "management", to: "site#management", as: :management
    get "events", to: "site#events", as: :events
    get "events/export", to: "site#events_export", as: :export_events
    root to: "forms#index"
    get "feed", to: "submissions#feed", as: :feed
    get "export_feed", to: "submissions#export_feed", as: :export_feed
  end

  get "profile", to: "profile#show", as: :profile
  patch "profile", to: "profile#update", as: :profile_update
  get "status", to: "site#status", as: :status
  get "index", to: "site#index", as: :index
  root to: redirect(ENV.fetch("INDEX_URL"))
end
