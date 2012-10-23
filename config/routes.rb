Mh::Application.routes.draw do
  get "dashboard/index"

  resources :imports, :only => [:show, :new, :create, :update, :destroy, :edit] do
    collection do
      get :download_sample_contacts_csv
      post :import
    end
  end
  match 'imports/:id/labels' => 'imports#labels'

  resources :group_labels, :only => [:create, :destroy]

  ActiveAdmin.routes(self)
  ActiveAdmin::ResourceController.class_eval do
    def authenticate_admin!
      unless user_signed_in? && SuperAdmin.find_by_user_id_and_site(current_user.id, 'MissionHub')
        render :file => Rails.root.join(mhub? ? 'public/404_mhub.html' : 'public/404.html'), :layout => false, :status => 404
        false
      end
    end
  end

  resources :groups do
    resources :group_labelings, :only => [:create, :destroy]
    resources :group_memberships, :only => [:create, :destroy] do
      collection do
        get :search
      end
    end
  end

  resources :survey_responses, :only => [:show, :new, :create, :edit, :update] do
    collection do
      get :thanks
      get :facebook
    end
  end

  resources :leaders, :only => [:new, :create, :update, :destroy] do
    collection do
      get :search
      put :add_person
    end
  end

  resources :organizational_roles, :only => :update do
    collection do
      post :move_to
    end
    member do
      get :set_current
      get :set_primary
    end
  end

  # resources :rejoicables

  resources :saved_contact_searches#, :only => [:show, :create, :edit, :destroy, :index]

  resources :followup_comments, :only => [:index, :create, :destroy]

  resources :contact_assignments, :only => [:create]

  resources :ministries

  resources :sms_keywords, :only => [:new, :create, :edit, :update, :destroy, :index] do
    collection do
      post :accept_twilio
    end
  end

  resources :people, :only => [:show, :create, :edit, :update, :destroy, :index] do
    collection do
      get :export
      get :merge
      post :confirm_merge
      post :do_merge
      get :search_ids
      post :bulk_email
      post :bulk_sms
      post :bulk_comment
      get :all
      post :update_roles
      post :bulk_delete
      post :bulk_archive
      get :facebook_search
    end
    member do
      get :merge_preview
      get :involvement
    end
  end

  resources :roles, :only => [:create, :update, :destroy, :index, :new, :edit] do
    collection do
      post :create_now
    end
  end

  namespace :admin do
    resources :email_templates
    
  end

  # namespace :admin do
  #   resources :organizations
  # end

  resources :organizations, :only => [:show, :new, :create, :edit, :update, :destroy, :index] do
    collection do
      get :search
      get :thanks
      post :signup
      get :settings
      post :update_settings
      get :cleanup
      post :archive_contacts
      post :archive_leaders
      post :create_from_crs
    end
  end

  resources :surveys, :only => [:new, :create, :edit, :update, :index, :destroy] do
    member do
      get :start
    end
    collection do
      get :index_admin
      get :stop
    end
    resources :questions, controller: "surveys/questions" do
      member do
        put :hide
        put :unhide
      end
      collection do
        post :reorder
      end
    end
  end
  
  match "/dashboard" => "dashboard#index"
  get "welcome/index"
  get "welcome/duplicate"
  match 'tutorials' => "welcome#tutorials"
  get "/test" => "welcome#test"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", sessions: "sessions" }
  devise_scope :user do
    get "sign_in", to: "sessions#new"
    get "sign_out", to: "sessions#destroy"
  end
  match '/auth/facebook/logout' => 'application#facebook_logout', as: :facebook_logout

  match "/application.manifest" => OFFLINE

  post "sms/mo"
  get "sms/mo"

  resources :contacts, :only => [:show, :create, :edit, :update, :destroy, :index] do
    collection do
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
    end
  end

  resources :vcards, :only => [:create] do
    collection do
      get :bulk_create
    end
  end

  namespace :api do
    scope '(/:version)', version: /v\d+?/ do  #module: :api
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
      get "contact_assignments/list_leaders" => "contact_assignments#list_leaders"
      get "contact_assignments/list_organizations" => "contact_assignments#list_organizations"
      resources :contact_assignments
      resources :followup_comments
      resources :roles
      resources :organizations
    end
  end

  root to: "welcome#index"
#  match 'home' => 'welcome#home', as: 'user_root' ---- LOOK FOR THIS IN application_controller.rb
  match 'wizard' => 'welcome#wizard', as: 'wizard'
  match 'terms' => 'welcome#terms', as: 'terms'
  match 'privacy' => 'welcome#privacy', as: 'privacy'

  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', as: 'sms_keyword_transition'
  match '/admin/sms_keywords/approve'

  match '/admin/organizations/:id/t/:transition' => 'admin/organizations#transition', as: 'organization_transition'
  match '/admin/organizations/approve'

  # Map keyword responses with phone numbers
  match 'c/:keyword(/:received_sms_id)' => 'survey_responses#new', as: 'contact_form'
  match 'm/:received_sms_id' => 'survey_responses#new'
  match 'l/:token/:user_id' => 'leaders#leader_sign_in', as: 'leader_link'
  get 's/:survey_id' => 'survey_responses#new', as: 'short_survey'
  get "/surveys/:keyword" => 'surveys#start'
  # mount RailsAdmin::Engine => "/admin"

  # 
  match 'autoassign_suggest' => 'surveys/questions#suggestion', as: 'question_suggestion'
  
  get "welcome/tour"

  # mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  mount Resque::Server.new, at: "/resque"

  #other oauth calls
  match "oauth/authorize" => "oauth#authorize"
  match "oauth/grant" => "oauth#grant"
  match "oauth/deny" => "oauth#deny"
  match "oauth/done" => "oauth#done"
  #make admin portion of oauth2 rack accessible
  mount Rack::OAuth2::Server::Admin =>"/oauth/admin"

  # Monitor
  match "monitor/:action", controller: 'monitor'
end
