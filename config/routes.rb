require 'sidekiq/pro/web'
require 'sidekiq/cron/web'

Mh::Application.routes.draw do
  post 'email_responses/bounce' => 'email_responses#bounce'
  post 'email_responses/complaint' => 'email_responses#complaint'

  constraint = lambda do |request|
    request.env['rack.session'] &&
    request.env['rack.session']['warden.user.user.key'] &&
    request.env['rack.session']['warden.user.user.key'].first &&
    request.env['rack.session']['warden.user.user.key'].first.first &&
    User.find(request.env['rack.session']['warden.user.user.key'].first.first).developer?
  end
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
  end

  match 'admin', to: 'application#redirect_admin', via: :get
  match 'admin/*path', to: 'application#redirect_admin', via: :all
  get 'admin/sms_keywords/:id', to: 'application#redirect_admin', as: 'admin_sms_keyword'
  get 'admin/organizations/:id', to: 'application#redirect_admin', as: 'admin_organization'

  resources :signatures, only: [] do
    collection do
      get :code_of_conduct
      get :statement_of_faith
      post :action_for_signature
    end
  end

  resources :saved_contact_searches, only: [:index, :create, :destroy] do
    collection do
      post :update
    end
  end

  resources :bulk_messages, only: [] do
    collection do
      post :sms
    end
  end

  resources :profile, only: [:show] do
    member do
      get :show, as: 'profile'
      post :change_avatar
      post :remove_avatar
      post :remove_facebook
    end
  end

  resources :movement_indicators, only: [:index, :create] do
    collection do
      get :details
      get :error
    end
  end

  resources :movement_indicator_suggestions do
    collection do
      get :fetch_suggestions
      get :fetch_declined_suggestions
      get :confirm
      post :post_to_infobase
      post :accept_all
    end
  end

  get 'dashboard/index'
  get '/d' => 'dashboard#index'
  get '/d/*all' => 'dashboard#index'

  resources :imports, except: [:show] do
    collection do
      get :download_sample_contacts_csv
      post :import
    end
    member do
      post :create_survey_question
    end
  end

  # Interactions
  resources :interactions do
    collection do
      get :change_followup_status
      get :reset_edit_form
      get :show_edit_interaction_form
      get :show_new_interaction_form
      get :search_initiators
      get :search_receivers
      get :load_more_interactions
      get :load_more_all_feeds
      get :create_label
      get :set_groups
      get :search_leaders
      get :remove_address
    end
  end

  get 'imports/:id/labels' => 'imports#labels'
  get 'show_assign_search' => 'contacts#show_assign_search'
  get 'show_hidden_questions' => 'contacts#show_hidden_questions'
  get 'show_search_hidden_questions' => 'contacts#show_search_hidden_questions'
  get 'display_sidebar' => 'contacts#display_sidebar'
  get 'display_new_sidebar' => 'contacts#display_new_sidebar'
  get 'show_other_orgs' => 'surveys#show_other_orgs'
  get 'copy_survey' => 'surveys#copy_survey'
  get 'sent_messages' => 'messages#sent_messages'
  get 'search_locate_contact' => 'contacts#search_locate_contact'

  resources :group_labels, only: [:create, :destroy]

  resources :groups do
    resources :group_labelings, only: [:create, :destroy]
    resources :group_memberships, only: [:create, :destroy] do
      collection do
        get :search
      end
    end
  end
  resources :group_memberships, only: [:create, :destroy] do
    collection do
      get :search
    end
  end

  get 'survey_responses/:id/answer_other_surveys' => 'survey_responses#answer_other_surveys', as: 'answer_other_surveys'
  resources :survey_responses do
    collection do
      get :thanks
      get :facebook
      get :live
    end
  end

  resources :leaders, only: [:new, :create, :update, :destroy] do
    collection do
      get :search
      post :find_by_email_addresses
      put :add_person
    end
  end

  resources :organizational_permissions, only: :update do
    collection do
      post :move_to
      post :update_all
    end
    member do
      get :set_current
      get :set_primary
    end
  end

  resources :organizational_labels do
    collection do
      post :update_all
    end
  end

  # resources :rejoicables
  resources :followup_comments, only: [:index, :create, :destroy]

  resources :contact_assignments, only: [:create] do
    collection do
      delete :destroy
    end
  end

  resources :sms_keywords, only: [:new, :create, :edit, :update, :destroy, :index] do
    collection do
      post :accept_twilio
    end
  end

  get '/people' => 'contacts#all_contacts'
  get '/allcontacts?assigned_to=unassigned' => 'contacts#all_contacts', as: 'unassigned_contacts'
  get '/contacts' => redirect('/allcontacts')
  get '/old_directory' => 'people#index'
  resources :people, only: [:show, :create, :edit, :update, :destroy] do
    collection do
      get :export
      get :merge
      post :confirm_merge
      post :do_merge
      get :hide_update_notice
      get :search_ids
      post :bulk_email
      post :bulk_comment
      get :all
      post :update_permissions
      post :update_permission_status
      post :bulk_delete
      post :bulk_archive
      get :facebook_search
      get :index
    end
    member do
      get :merge_preview
      get :involvement
    end
  end

  resources :labels, only: [:create, :update, :destroy, :index, :new, :edit] do
    collection do
      post :create_now
      post :add_label
      post :edit_label
    end
  end

  get 'load_organization_tree' => 'organizations#load_tree'
  resources :organizations, only: [:show, :new, :create, :edit, :update, :destroy, :index] do
    collection do
      get :search
      get :thanks
      post :signup
      get :settings
      post :update_settings
      get :cleanup
      get :transfer
      get :available_for_transfer
      get :queue_transfer
      post :do_transfer
      post :archive_contacts
      post :archive_leaders
      post :create_from_crs
      get :api
      get :generate_api_secret
      get :show_hidden_questions
      get :display_sidebar
      get :signatures
    end
    member do
      get :update_from_crs
    end
  end

  resources :charts do
    collection do
      get :snapshot
      post :save_snapshot
      post :delete_snapshot
      post :save_trend
      post :delete_trend
      post :update_snapshot_movements
      post :update_snapshot_range
      get :goal
      post :update_goal_org
      post :update_goal_criteria
      get :edit_goal
      get :cancel_edit_goal
      post :update_goal
      put :update_goal
      patch :update_goal
      get :goal_empty
      get :trend
      post :update_trend_movements
      post :update_trend_field
      post :update_trend_compare
    end
  end

  resources :surveys, only: [:new, :create, :edit, :update, :index, :destroy] do
    member do
      get :start
      get :mass_entry
      get :mass_entry_data
      post :mass_entry_save
    end
    collection do
      get :index_admin
      get :stop
      post :create_label
      post :remove_logo
    end
    resources :questions, controller: 'surveys/questions' do
      collection do
        post :reorder
      end
    end
  end

  devise_for :users, controllers: { sessions: 'sessions' }

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end
  root 'welcome#index'

  devise_scope :user do
    get '/sign_in', to: 'sessions#new'
    get '/sign_out', to: 'sessions#destroy'
    get '/users/auth/facebook/callback', to: 'users/omniauth_callbacks#facebook'
    get '/users/auth/facebook_mhub/callback', to: 'users/omniauth_callbacks#facebook_mhub'
    get '/users/auth/relay/callback', to: 'users/omniauth_callbacks#relay'
    get '/users/auth/key/callback', to: 'users/omniauth_callbacks#key'
  end
  get '/auth/facebook/logout' => 'application#facebook_logout', as: :facebook_logout

  get '/application.manifest' => OFFLINE

  post 'sms/mo'
  get 'sms/mo'

  get '/allcontacts' => 'contacts#all_contacts', as: 'all_contacts'
  get '/mycontacts' => 'contacts#my_contacts', as: 'my_contacts'
  get '/my_contacts_all' => 'contacts#my_contacts_all', as: 'my_contacts_all'
  resources :contacts do
    collection do
      post :unhide_questions
      get :filter
      get :update_advanced_search_surveys
      post :bulk_update
      get :all_contacts
      get :my_contacts
      get :mine
      get :mine_all
      get :contacts_all
      post :send_reminder
      put :create_from_survey
      delete :destroy
      post :bulk_destroy
      post :send_vcard
      get :send_bulk_vcard
      get :import_contacts
      post :csv_import
      get :download_sample_contacts_csv
      get :search_by_name_and_email
      get :auto_suggest_send_email
      get :auto_suggest_send_text
      post :hide_question_column
      post :unhide_question_column

      post :add_contact_check_email
      post :set_permissions
      post :set_labels

      post :export_csv
    end
  end

  resources :vcards, only: [:create] do
    collection do
      get :bulk_create
    end
  end

  resources :callbacks, only: [] do
    collection do
      post :twilio_status
    end
  end

  resources :report_emails do
    collection do
      get :leader_digest
    end
  end

  namespace :api do
    scope '(/:version)', version: /v\d+?/ do # module: :api
      resources :people do
        collection do
          get :leaders
        end
      end
      resources :friends
      get 'contacts/search' => 'contacts#search'
      resources :contacts do
        resource :photo
      end
      get 'contact_assignments/list_leaders' => 'contact_assignments#list_leaders'
      get 'contact_assignments/list_organizations' => 'contact_assignments#list_organizations'
      resources :contact_assignments
      resources :followup_comments
      resources :interactions
      resources :roles
      resources :permissions
      resources :organizational_labels
      resources :organizational_permissions
      resources :organizations
    end
  end

  namespace :apis do
    api_version(module: 'V3', header: { name: 'API-VERSION', value: 'v3' }, parameter: { name: 'version', value: 'v3' }, path: { value: 'v3' }) do
      resources :contact_assignments do
        collection do
          put :bulk_update
          delete :bulk_destroy
        end
      end
      resources :people do
        collection do
          get :ids
          post :archive
          delete :bulk_destroy
          post :bulk_archive
        end
      end
      resources :organizations
      resources :answers
      resources :surveys do
        resources :questions
      end
      resources :questions
      resources :followup_comments
      resources :roles
      resources :organizational_roles
      resources :interactions
      resources :interaction_types
      resources :labels
      resources :permissions
      resources :organizational_labels do
        collection do
          post :bulk
          post :bulk_create
          delete :bulk_destroy
        end
      end
      resources :organizational_permissions do
        collection do
          post :archive
          post :bulk
          post :bulk_create
          post :bulk_archive
          delete :bulk_destroy
        end
      end
    end
  end

  resources :preferences, only: :index

  #  get 'home' => 'welcome#home', as: 'user_root' ---- LOOK FOR THIS IN application_controller.rb
  get 'dashboard' => 'dashboard#index'
  get 'wizard' => 'welcome#wizard', as: 'wizard'
  get 'terms', to: redirect('https://get.missionhub.com/terms-of-service/')
  get 'privacy', to: redirect('https://get.missionhub.com/terms-of-service/')
  get 'tutorials', to: redirect('http://help.missionhub.com/')
  get 'get_missionhub', to: redirect('https://get.missionhub.com/')
  get 'test' => 'welcome#test'
  get 'welcome/index'
  get 'welcome/duplicate'
  get 'request_access' => 'welcome#request_access', as: 'request_access'
  post 'requested_access' => 'welcome#requested_access', as: 'requested_access'
  get 'thank_you' => 'welcome#thank_you', as: 'thank_you'

  # Map keyword responses with phone numbers
  get 'c/:keyword(/:received_sms_id)' => 'survey_responses#new', as: 'contact_form'
  get 'm/:received_sms_id' => 'survey_responses#new'
  get 'l/:token/:user_id' => 'leaders#leader_sign_in', as: 'leader_link'
  get 'l/:token/:user_id/merge' => 'leaders#merge_leader_accounts', as: 'merge_leader_link'
  get 'l/:token/:user_id/signout' => 'leaders#sign_out_and_leader_sign_in', as: 'sign_out_and_leader_sign_in'
  get 's/:survey_id' => 'survey_responses#new', as: 'short_survey'
  get '/surveys/:keyword' => 'surveys#start'

  get 'autoassign_suggest' => 'surveys/questions#suggestion', as: 'question_suggestion'
  get 'add_survey_question/:survey_id' => 'surveys/questions#add', as: 'add_survey_question'

  # mount Resque::Server.new, at: "/resque"

  # other oauth calls
  get 'oauth/authorize' => 'oauth#authorize'
  get 'oauth/grant' => 'oauth#grant'
  get 'oauth/deny' => 'oauth#deny'
  get 'oauth/done' => 'oauth#done'
  scope 'v4' do
    use_doorkeeper
  end
  # make admin portion of oauth2 rack accessible
  mount Rack::OAuth2::Server::Admin => '/oauth/admin'

  get 'monitors/lb'
  get 'monitors/commit'
end
