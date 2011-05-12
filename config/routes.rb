Ma::Application.routes.draw do
  
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

  root :to => "welcome#index"
  match 'home' => "sms_keywords#index", :as => 'user_root'
  
  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', :as => 'sms_keyword_transition'

  # Map keyword responses with phone numbers
  match 'c/:keyword(/:received_sms_id)' => 'contacts#new', :as => 'contact_form'
end
