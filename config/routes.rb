# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  resources :ivn_components
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end

  get 'hello_stimulus', to: 'site#hello_stimulus', as: :hello_stimulus if Rails.env.development?
  get 'docs', to: 'site#docs', as: :docs if Rails.env.development?

  unless Rails.env.development?
    match '/404', to: 'errors#not_found', via: :all
    match '/500', to: 'errors#internal_server_error', via: :all
  end

  resources :forms, only: [:show] do
    member do
      get 'js', to: 'touchpoints#js', as: :js_form
      get 'submit', to: 'submissions#new', form: true, as: :submit
    end
    resources :submissions, only: %i[new create]
  end

  resources :touchpoints, only: [:show] do
    member do
      get 'js', to: 'touchpoints#js', as: :js
      get 'submit', to: 'submissions#new', form: true, as: :submit
    end
    resources :submissions, only: %i[new create]
  end

  namespace :api do
    namespace :v0 do
      resources :forms, only: %i[index show]
    end
    namespace :v1 do
      resources :organizations, only: [:index]
      resources :collections, only: [:index]
      resources :cx_responses, only: [:index]
      resources :cx_collections, only: [:index]
      resources :cx_collection_details, only: [:index]
      resources :forms, only: %i[index show]
      resources :websites, only: [:index]
      resources :service_providers, only: [:index]
      resources :cx_action_plans, only: %i[index show]
      resources :services, only: %i[index show]
      resources :personas, only: [:index]
      resources :users, only: [:index]
      resources :digital_products, only: %i[index show]
      resources :digital_service_accounts, only: %i[index show]
    end
  end

  namespace :admin do
    get 'invite', to: 'site#invite', as: :invite
    patch 'invite', to: 'site#invite_post'

    resources :ivn_source_component_links
    resources :ivn_links
    resources :ivn_sources
    resources :ivn_components

    get '/reporting/', to: 'reporting#index', as: :reporting
    get '/reporting/hisps/hisps', to: 'reporting#hisps', as: :hisps
    get '/reporting/hisps/hisp_services', to: 'reporting#hisp_services', as: :hisp_services
    get '/reporting/hisps/hisp_service_cx_data_collections', to: 'reporting#hisp_service_cx_data_collections', as: :hisp_service_cx_data_collections
    get '/reporting/hisps/hisp_service_cx_data_collections_summary', to: 'reporting#hisp_service_cx_data_collections_summary', as: :hisp_service_cx_data_collections_summary
    get '/reporting/hisps/hisp_service_questions', to: 'reporting#hisp_service_questions', as: :hisp_service_questions

    get '/reporting/lifespan', to: 'reporting#lifespan', as: :lifespan
    get '/reporting/no_submissions', to: 'reporting#no_submissions', as: :no_submissions
    get '/reporting/service_surveys', to: 'reporting#service_surveys', as: :service_surveys
    get '/reporting/users', to: 'reporting#users', as: :user_reporting
    get '/reporting/form_whitelist', to: 'reporting#form_whitelist', as: :form_whitelist_reporting
    get '/reporting/form_logos', to: 'reporting#form_logos', as: :form_logos
    get '/submissions/search', to: 'submissions#search', as: :search_submissions
    get '/submissions/a11_analysis', to: 'submissions#a11_analysis', as: :a11_analysis
    get '/submissions/a11_chart', to: 'submissions#a11_chart', as: :a11_chart
    get '/submissions/responses_per_day', to: 'submissions#responses_per_day', as: :responses_per_day
    get '/submissions/responses_by_status', to: 'submissions#responses_by_status', as: :responses_by_status
    get '/submissions/submissions_table', to: 'submissions#submissions_table', as: :submissions_table
    get '/submissions/performance_gov', to: 'submissions#performance_gov', as: :performance_gov

    get 'heartbeat', to: 'site#heartbeat', as: :heartbeat
    resources :offerings do
      member do
        post 'add_offering_persona', to: 'offerings#add_offering_persona', as: :add_offering_persona
        post 'remove_offering_persona', to: 'offerings#remove_offering_persona', as: :remove_offering_persona
      end
    end
    resources :service_providers do |*_args|
      collection do
        get 'quadrants', to: 'service_providers#quadrants', as: :quadrants
        get 'search', to: 'service_providers#search', as: :search
      end
      member do
        post 'add_tag', to: 'service_providers#add_tag', as: :add_tag
        delete 'remove_tag', to: 'service_providers#remove_tag', as: :remove_tag
        post 'add_service_provider_manager', to: 'service_providers#add_service_provider_manager', as: :add_service_provider_manager
        delete 'remove_service_provider_manager', to: 'service_providers#remove_service_provider_manager', as: :remove_service_provider_manager
      end
    end
    resources :cx_action_plans
    resources :services do
      collection do
        get 'catalog', to: 'services#catalog', as: :catalog
        get 'search', to: 'services#search', as: :search
        get 'export_csv', to: 'services#export_csv', as: :export_csv
      end
      member do
        get 'equity-assessment', to: 'services#equity_assessment', as: :equity_assessment
        post 'add_tag', to: 'services#add_tag', as: :add_tag
        delete 'remove_tag', to: 'services#remove_tag', as: :remove_tag
        post 'add_channel', to: 'services#add_channel', as: :add_channel
        delete 'remove_channel', to: 'services#remove_channel', as: :remove_channel

        post 'add_service_manager', to: 'services#add_service_manager', as: :add_service_manager
        delete 'remove_service_manager', to: 'services#remove_service_manager', as: :remove_service_manager

        post 'submit', to: 'services#submit', as: :submit
        post 'approve', to: 'services#approve', as: :approve
        post 'verify', to: 'services#verify', as: :verify
        post 'archive', to: 'services#archive', as: :archive
        post 'reset', to: 'services#reset', as: :reset
        get 'versions', to: 'services#versions', as: :versions
        get 'versions_export', to: 'services#export_versions', as: :export_versions
      end

      resources :service_stages
    end

    resources :cx_collections do
      collection do
        get 'export_csv', to: 'cx_collections#export_csv', as: :export_csv
        get 'export_cx_responses_csv', to: 'cx_collections#export_cx_responses_csv', as: :export_cx_responses_csv
      end
      member do
        post 'copy', to: 'cx_collections#copy', as: :copy
        post 'submit', to: 'cx_collections#submit', as: :submit
        post 'publish', to: 'cx_collections#publish', as: :publish
        post 'reset', to: 'cx_collections#reset', as: :reset
        post 'no_report', to: 'cx_collections#no_report', as: :no_report
        get 'events', to: 'cx_collections#events', as: :events
      end
    end

    resources :cx_collection_details do
      collection do
        get 'export_csv', to: 'cx_collection_details#export_csv', as: :export_csv
      end
      member do
        get 'upload', to: 'cx_collection_details#upload', as: :upload
        post 'upload', to: 'cx_collection_details#upload_csv', as: :post_csv
        post 'process/:cx_collection_detail_upload_id', to: 'cx_collection_details#process_csv', as: :process
      end
      resources :cx_collection_detail_uploads, only: [:destroy] do
      end
    end

    get '/a11_v2_collections', to: 'site#a11_v2_collections'

    resources :cscrm_data_collections do
      member do
        post 'submit', to: 'cscrm_data_collections#submit', as: :submit
        post 'publish', to: 'cscrm_data_collections#publish', as: :publish
        post 'reset', to: 'cscrm_data_collections#reset', as: :reset
      end
    end
    resources :cscrm_data_collections2 do
      member do
        post 'submit', to: 'cscrm_data_collections2#submit', as: :submit
        post 'publish', to: 'cscrm_data_collections2#publish', as: :publish
        post 'reset', to: 'cscrm_data_collections2#reset', as: :reset
      end
    end

    resources :websites do
      collection do
        get :review, to: 'websites#review'
        get 'search', to: 'websites#search'
        get 'gsa', to: 'websites#gsa'
        get 'dendrogram', to: 'websites#dendrogram', as: :dendrogram
        get 'dendrogram_json', to: 'websites#dendrogram_json', as: :dendrogram_json
        get 'export_csv', to: 'websites#export_csv', as: :export_csv
        get 'collection_preview', to: 'websites#collection_preview', as: :collection_preview
      end
      member do
        get 'costs', to: 'websites#costs', as: :costs
        get 'statuscard', to: 'websites#statuscard', as: :statuscard
        get 'collection_request', to: 'websites#collection_request', as: :collection_request
        post 'submit', to: 'websites#submit', as: :submit
        post 'publish', to: 'websites#publish', as: :publish

        post 'stage', to: 'websites#stage', as: :stage
        post 'launch', to: 'websites#launch', as: :launch
        post 'redirect', to: 'websites#redirect', as: :redirect
        post 'archive', to: 'websites#archive', as: :archive
        post 'decommission', to: 'websites#decommission', as: :decommission
        post 'reset', to: 'websites#reset', as: :reset
        get 'events', to: 'websites#events', as: :events
        post 'add_tag', to: 'websites#add_tag', as: :add_tag
        delete 'remove_tag', to: 'websites#remove_tag', as: :remove_tag
        get 'versions', to: 'websites#versions', as: :versions
        get 'versions_export', to: 'websites#export_versions', as: :export_versions
        post 'add_website_manager', to: 'websites#add_website_manager', as: :add_website_manager
        post 'remove_website_manager', to: 'websites#remove_website_manager', as: :remove_website_manager
        post 'add_website_persona', to: 'websites#add_website_persona', as: :add_website_persona
        delete 'remove_website_persona', to: 'websites#remove_website_persona', as: :remove_website_persona
      end
    end
    get :registry, to: 'site#registry', as: :registry

    resources :digital_service_accounts do
      collection do
        get :search, to: 'digital_service_accounts#search'
        get :review, to: 'digital_service_accounts#review'
        get :export, to: 'digital_service_accounts#export'
      end
      member do
        post 'submit', to: 'digital_service_accounts#submit', as: :submit
        post 'publish', to: 'digital_service_accounts#publish', as: :publish
        post 'archive', to: 'digital_service_accounts#archive', as: :archive
        post 'reset', to: 'digital_service_accounts#reset', as: :reset
        post 'add_tag', to: 'digital_service_accounts#add_tag', as: :add_tag
        delete 'remove_tag', to: 'digital_service_accounts#remove_tag', as: :remove_tag

        post 'add_organization', to: 'digital_service_accounts#add_organization', as: :add_organization
        delete 'remove_organization', to: 'digital_service_accounts#remove_organization', as: :remove_organization

        post 'add_user', to: 'digital_service_accounts#add_user', as: :add_user
        delete 'remove_user', to: 'digital_service_accounts#remove_user', as: :remove_user
      end
    end

    resources :digital_products do
      collection do
        get 'search', to: 'digital_products#search'
        get 'review', to: 'digital_products#review'
      end
      member do
        post 'submit', to: 'digital_products#submit', as: :submit
        post 'publish', to: 'digital_products#publish', as: :publish
        post 'archive', to: 'digital_products#archive', as: :archive
        post 'reset', to: 'digital_products#reset', as: :reset

        post 'add_tag', to: 'digital_products#add_tag', as: :add_tag
        delete 'remove_tag', to: 'digital_products#remove_tag', as: :remove_tag

        post 'add_organization', to: 'digital_products#add_organization', as: :add_organization
        delete 'remove_organization', to: 'digital_products#remove_organization', as: :remove_organization

        post 'add_user', to: 'digital_products#add_user', as: :add_user
        delete 'remove_user', to: 'digital_products#remove_user', as: :remove_user
      end
      resources :digital_product_versions
      resources :digital_product_platforms
    end

    resources :personas do
      member do
        post 'add_tag', to: 'personas#add_tag', as: :add_tag
        delete 'remove_tag', to: 'personas#remove_tag', as: :remove_tag
      end
    end

    resources :forms do
      member do
        get 'notifications', to: 'forms#notifications', as: :notifications
        get 'example', to: 'forms#example', as: :example
        get 'export', to: 'forms#export', as: :export
        get 'export_form_and_a11_v2_submissions', to: 'forms#export_form_and_a11_v2_submissions', as: :export_form_and_a11_v2_submissions
        get 'export_a11_v2_submissions', to: 'forms#export_a11_v2_submissions', as: :export_a11_v2_submissions
        get 'export_a11_header', to: 'forms#export_a11_header', as: :export_a11_header
        get 'export_a11_submissions', to: 'forms#export_a11_submissions', as: :export_a11_submissions
        get 'js', to: 'forms#js', as: :js
        post 'add_tag', to: 'forms#add_tag', as: :add_tag
        delete 'remove_tag', to: 'forms#remove_tag', as: :remove_tag
        get 'permissions', to: 'forms#permissions', as: :permissions
        get 'compliance', to: 'forms#compliance', as: :compliance
        get 'questions', to: 'forms#questions', as: :questions
        get 'responses', to: 'forms#responses', as: :responses
        get 'delivery', to: 'forms#delivery', as: :delivery
        post 'add_user', to: 'forms#add_user', as: :add_user
        post 'copy', to: 'forms#copy', as: :copy
        post 'submit', to: 'forms#submit', as: :submit
        post 'approve', to: 'forms#approve', as: :approve
        post 'publish', to: 'forms#publish', as: :publish
        post 'archive', to: 'forms#archive', as: :archive
        post 'reset', to: 'forms#reset', as: :reset
        delete 'remove_user', to: 'forms#remove_user', as: :remove_user
        patch 'update_title', to: 'forms#update_title', as: :update_title
        patch 'update_instructions', to: 'forms#update_instructions', as: :update_instructions
        patch 'update_disclaimer_text', to: 'forms#update_disclaimer_text', as: :update_disclaimer_text
        patch 'update_success_text', to: 'forms#update_success_text', as: :update_success_text
        patch 'update_ui_truncation', to: 'forms#update_ui_truncation', as: :update_ui_truncation
        patch 'update_display_logo', to: 'forms#update_display_logo', as: :update_display_logo
        patch 'update_notification_emails', to: 'forms#update_notification_emails', as: :update_notification_emails
        patch 'update_admin_options', to: 'forms#update_admin_options', as: :update_admin_options
        patch 'update_form_manager_options', to: 'forms#update_form_manager_options', as: :update_form_manager_options
        get 'events', to: 'forms#events', as: :events
      end
      collection do
        post 'copy', to: 'forms#copy', as: :copy_id
      end
      resources :form_sections, except: %i[index show edit] do
        patch 'sort', to: 'form_sections#sort', as: :sort_sections
        patch 'update_title', to: 'form_sections#update_title', as: :inline_update
      end
      resources :questions do
        member do
          patch 'question_options', to: 'question_options#sort', as: :sort_question_options
        end
        resources :question_options, except: %i[index show] do
          patch 'update_title', to: 'question_options#update_title', as: :inline_update
          collection do
            post 'create_other', to: 'question_options#create_other', as: :create_other
          end
        end
        collection do
          patch 'sort', to: 'questions#sort', as: :sort_questions
        end
      end
      resources :submissions, only: %i[show update destroy] do
        member do
          post 'flag', to: 'submissions#flag', as: :flag
          post 'unflag', to: 'submissions#unflag', as: :unflag
          post 'archive', to: 'submissions#archive', as: :archive
          post 'unarchive', to: 'submissions#unarchive', as: :unarchive
          post 'add_tag', to: 'submissions#add_tag', as: :add_tag
          delete 'remove_tag', to: 'submissions#remove_tag', as: :remove_tag
        end
      end
    end
    resources :users, except: [:new] do
      member do
        post 'reactivate', to: 'users#reactivate', as: :reactivate
      end
      collection do
        get 'all', to: 'users#index', as: :all, scope: :all
        get 'inactive', to: 'users#index', as: :inactive, scope: :inactive
        get 'admins', to: 'users#admins', as: :admins
        post 'inactivate', to: 'users#inactivate!', as: :inactivate
        get 'deactivate', to: 'users#deactivate'
      end
    end
    resources :organizations do
      collection do
        get 'search', to: 'organizations#search'
      end
      member do
        patch 'performance_update', to: 'organizations#performance_update', as: :performance_update
        get 'performance', to: 'organizations#performance', as: :performance
        get 'performance/edit', to: 'performance#edit', as: :performance_edit
        post 'add_tag', to: 'organizations#add_tag', as: :add_tag
        delete 'remove_tag', to: 'organizations#remove_tag', as: :remove_tag
      end
    end
    resources :service_stages do
      collection do
        get 'export_csv', to: 'service_stages#export_csv', as: :export_csv
      end
    end
    resources :barriers
    resources :service_stage_barriers

    get 'dashboard', to: 'site#index', as: :dashboard
    get 'integrations', to: 'site#integrations', as: :integrations
    get 'performance', to: 'performance#index', as: :performance
    post 'quarterly_peformance_notification', to: 'performance#quarterly_performance_notification', as: 'quarterly_performance_notification'
    get 'performance/apg', to: 'performance#apgs', as: :apgs
    get 'management', to: 'site#management', as: :management
    get 'events', to: 'events#index', as: :events
    get 'events/export', to: 'events#export', as: :export_events
    get 'events/:id', to: 'events#show', as: :event
    get 'retention', to: 'record_retention#index', as: :record_retention
    get 'retention/export_form_managers', to: 'record_retention#export_form_managers', as: :record_retention_export
    root to: 'forms#index'
    get 'feed', to: 'submissions#feed', as: :feed
    get 'export_feed', to: 'submissions#export_feed', as: :export_feed
  end

  get 'profile', to: 'profile#show', as: :profile
  patch 'profile', to: 'profile#update', as: :profile_update
  get 'status', to: 'site#status', as: :status
  get 'registry', to: 'site#registry', as: :registry
  get 'index', to: 'site#index', as: :index
  root to: redirect(ENV.fetch('INDEX_URL'))
end
