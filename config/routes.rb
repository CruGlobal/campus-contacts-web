Mh::Application.routes.draw do
  
  resources :rejoicables

  resources :followup_comments

  resources :contact_assignments

  resources :organization_memberships

  resources :schools
  resources :communities

  resources :ministries

  resources :sms_keywords do
    resources :questions, :controller => "sms_keywords/questions" do
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
                :controller => :question_pages do         # question_sheet_pages_path(),
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

  get "welcome/index"
  get "/test" => "welcome#test"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :sessions => "sessions" }
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_out", :to => "devise/sessions#destroy"
  end
  
  match "/application.manifest" => OFFLINE
  mount Resque::Server.new, :at => "/resque"
  
  post "sms/mo"
  
  resources :contacts do
    collection do
      get :thanks
      get :mine
    end
  end

  namespace :api do
    scope '(/:version)', :version => /v\d+?/ do  #:module => :api
      resources :people
      resources :friends
      get 'contacts/search' => 'contacts#search'
      resources :contacts
      resources :contact_assignments
      resources :followup_comments
      get 'schools' => 'people#schools'
    end
  end

  #other oauth calls
  match "oauth/authorize" => "oauth#authorize"
  match "oauth/grant" => "oauth#grant"
  match "oauth/deny" => "oauth#deny"
  match "oauth/done" => "oauth#done"
  #make admin portion of oauth2 rack accessible
  mount Rack::OAuth2::Server::Admin =>"/oauth/admin"

  root :to => "welcome#index"
  match 'home' => 'welcome#home', :as => 'user_root'
  match 'wizard' => 'welcome#wizard', :as => 'wizard'
  match 'verify_with_relay' => 'welcome#verify_with_relay', :as => 'verify_with_relay'
  
  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', :as => 'sms_keyword_transition'

  # Map keyword responses with phone numbers
  match 'c/:keyword(/:received_sms_id)' => 'contacts#new', :as => 'contact_form'
  match 'm/:received_sms_id' => 'contacts#new'
end
