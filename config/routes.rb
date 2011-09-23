Mh::Application.routes.draw do
  
  resources :leaders do
    collection do
      post :search
      put :add_person
    end
  end
  
  resources :organizational_roles do
    collection do
      post :move_to
    end
  end
  
  resources :rejoicables

  resources :followup_comments

  resources :contact_assignments

  resources :organization_memberships do
    member do
      get :set_current
      get :set_primary
    end
  end

  resources :schools
  resources :communities

  resources :ministries

  resources :sms_keywords do
    resources :questions, controller: "sms_keywords/questions" do
      member do
        put :hide
        put :unhide
      end
      collection do
        post :reorder
      end
    end 
  end
  
  resources :people do
    collection do
      get :export
      get :merge
      post :confirm_merge
      post :do_merge
      get :search_ids
    end
    member do
      get :merge_preview
    end
    resources :organization_memberships do
      member do
        get :validate
      end
    end
  end
  
  namespace :admin do
    resources :email_templates
    resources :question_sheets do 
      member do
        post :archive
        post :unarchive
        post :duplicate
      end
      resources :pages,                               # pages/
                controller: :question_pages do         # question_sheet_pages_path(),
                collection do
                  post :reorder
                end
                member do
                  get :show_panel
                end
        resources :elements do
                  collection do
                    post :reorder
                  end
                  member do
                    get :remove_from_grid
                    post :use_existing
                    post :drop
                    post :duplicate
                  end
                end
      end
    end
  end
  
  # namespace :admin do
  #   resources :organizations
  # end
  
  resources :organizations do
    collection do
      get :search
    end
  end
  
  get "/surveys" => 'surveys#index'
  get "/surveys/stopsurveymode" => 'surveys#stop', as: :stop_survey
  get "/surveys/:keyword" => 'surveys#start', as: :start_survey

  get "welcome/index"
  get "/test" => "welcome#test"

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks", sessions: "sessions" }
  devise_scope :user do
    get "sign_in", to: "sessions#new"
    get "sign_out", to: "sessions#destroy"
  end
  match '/auth/facebook/logout' => 'application#facebook_logout', as: :facebook_logout
  
  match "/application.manifest" => OFFLINE
  
  post "sms/mo"
  
  resources :contacts do
    collection do
      get :thanks
      get :mine
      post :send_reminder
    end
  end

  namespace :api do
    scope '(/:version)', version: /v\d+?/ do  #module: :api
      resources :people
      resources :friends
      get 'contacts/search' => 'contacts#search'
      resources :contacts
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
  match 'verify_with_relay' => 'welcome#verify_with_relay', as: 'verify_with_relay'
  
  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', as: 'sms_keyword_transition'
  match '/admin/sms_keywords/approve'

  # Map keyword responses with phone numbers
  match 'c/:keyword(/:received_sms_id)' => 'contacts#new', as: 'contact_form'
  match 'm/:received_sms_id' => 'contacts#new'
  match 'l/:token/:user_id' => 'leaders#leader_sign_in'
  # mount RailsAdmin::Engine => "/admin"
  
  get "welcome/tour"
  
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
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
