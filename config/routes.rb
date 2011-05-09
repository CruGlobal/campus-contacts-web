Ma::Application.routes.draw do
  resources :organization_memberships

  resources :schools
  resources :communities

  resources :ministries

  resources :sms_keywords
  
  resources :people do
    resources :organization_memberships do
      member do
        get :validate
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
  
  # SMS keyword state transitions
  match '/admin/sms_keywords/:id/t/:transition' => 'admin/sms_keywords#transition', :as => 'sms_keyword_transition'

  # Map keyword responses with phone numbers
  # match ':keyword(/:received_sms_id)' => 'contacts#new'
end
