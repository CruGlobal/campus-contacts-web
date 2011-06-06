Ma::Application.routes.draw do
  
  resources :contact_assignments

  resources :organization_memberships

  resources :schools
  resources :communities

  resources :ministries

  resources :sms_keywords do
    resources :questions, :controller => "SmsKeywords::Questions" do
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

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
  end
  
  match "/application.manifest" => OFFLINE
  mount Resque::Server.new, :at => "/resque"
  
  post "sms/mo"
  
  resources :contacts do
    collection do
      get :thanks
    end
  end

  #test validated api call
  scope 'api(/:version)', :module => :api, :version => /v\d+?/ do
    resources :users
    resources :friends
    resources :contacts
    #get 'user/:id' => 'user#user', :as => "api_user_view"
    #get 'user/:id/friends' => 'user#friends', :as => "api_user_friends"
    get 'schools' => 'users#schools'
  end

  #other oauth calls
  match "oauth/authorize" => "oauth#authorize"
  match "oauth/grant" => "oauth#grant"
  match "oauth/deny" => "oauth#deny"
  #make admin portion of oauth2 rack accessible
  #mount Rack::OAuth2::Server::Admin, :at => "/oauth/admin"
  mount Rack::OAuth2::Server::Admin => "/oauth/admin"
  
  root :to => "welcome#index"
  match 'home' => 'welcome#home', :as => 'user_root'
  
  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', :as => 'sms_keyword_transition'

  # Map keyword responses with phone numbers
  match 'c/:keyword(/:received_sms_id)' => 'contacts#new', :as => 'contact_form'
  match 'm/:received_sms_id' => 'contacts#new'
end
