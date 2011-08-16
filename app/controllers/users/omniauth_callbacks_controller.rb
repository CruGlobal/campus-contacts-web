class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  def facebook
    facebook_login and return
  end
  
  def facebook_mhub
    env["omniauth.auth"]['provider'] = 'facebook'
    facebook_login and return
  end
  
  protected
  
  def facebook_login
    begin
      User.transaction do
        @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
        omniauth = env["omniauth.auth"]
        session[:fb_token] = omniauth["credentials"]["token"]
   
        if @user && @user.persisted?
          sign_in_and_redirect(@user, event: :authentication) and return
        else
          # There was a problem logging this person in
          HoptoadNotifier.notify(
            :error_class => "FacebookLoginError",
            :error_messsage => "Facebook Login Error",
            :parameters => env["omniauth.auth"]
          )
          session["devise.facebook_data"] = env["omniauth.auth"]
          redirect_to '/' and return
        end
      end
    rescue => e
      notify_hoptoad(e)
      redirect_to '/' and return
    end
  end
end
