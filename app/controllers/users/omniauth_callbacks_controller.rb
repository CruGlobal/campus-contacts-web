class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!
  def facebook
    @user = User.find_for_facebook_oauth(env["omniauth.auth"], current_user)
    omniauth = env["omniauth.auth"]
    session[:fb_token] = omniauth["credentials"]["token"] if omniauth['provider'] == 'facebook'
   
    if @user && @user.persisted?
      sign_in_and_redirect @user, event: :authentication
    else
      # There was a problem logging this person in
      HoptoadNotifier.notify(
        :error_class => "FacebookLoginError",
        :error_messsage => "Facebook Login Error",
        :parameters => env["omniauth.auth"]
      )
      session["devise.facebook_data"] = env["omniauth.auth"]
      redirect_to '/'
    end
  end
end
