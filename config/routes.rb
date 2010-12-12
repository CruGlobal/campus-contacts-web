Bonfire::Application.routes.draw do
  devise_for :users
  match "/application.manifest" => OFFLINE
  mount Resque::Server.new, :at => "/resque"
  
  post "sms/mo"
  
  resources :contacts do
    collection do
      get :thanks
    end
  end

  root :to => "welcome#index"

  # Map keyword responses with phone numbers
  match ':keyword(/:received_sms_id)' => 'welcome#index'
end
