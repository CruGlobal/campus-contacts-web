class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  def facebook
    facebook_login
    redirect_to redirect_location(:user, @user)
  end
  
  def facebook_mhub
    env["omniauth.auth"]['provider'] = 'facebook'
    facebook_login
    redirect_to stored_location_for(:user) || '/'
  end
  
  protected
  
  def facebook_login
    begin
      @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
      omniauth = env["omniauth.auth"]
      session[:fb_token] = omniauth["credentials"]["token"]
   
      if @user && @user.persisted?
        sign_in(@user)
      else
        # There was a problem logging this person in
        # This usually means the data coming back from FB didn't include an email address
        HoptoadNotifier.notify(
          :error_class => "FacebookLoginError",
          :error_messsage => "Facebook Login Error",
          :parameters => env["omniauth.auth"]
        )
        session["devise.facebook_data"] = env["omniauth.auth"]
      end
    rescue Exception => e
      if Rails.env.test?
        raise e 
      else
        notify_hoptoad(e)
      end
    end
  end
end
