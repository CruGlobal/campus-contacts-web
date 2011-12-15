class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  def facebook
    begin
      facebook_login
      redirect_to @user ? redirect_location(:user, @user) : '/'
    rescue NoEmailError
      flash[:error] = t('.email_required')
      redirect_to '/users/sign_in'
    rescue FailedFacebookCreateError
      redirect_to '/users/sign_in'
    end
  end
  
  def facebook_mhub
    env["omniauth.auth"]['provider'] = 'facebook'
    begin
      facebook_login
      location = stored_location_for(:user)
      if location.present?
        redirect_to location
      else
        render_404
      end
    rescue NoEmailError, FailedFacebookCreateError
      render_404(true)
    end
  end
  
  protected
  
  def facebook_login
    omniauth = env["omniauth.auth"]
    @user = User.find_for_facebook_oauth(omniauth, current_user)
    session[:fb_token] = omniauth["credentials"]["token"]
    session["devise.facebook_data"] = omniauth
 
    if @user && @user.persisted?
      sign_in(@user)
    else
      # There was a problem logging this person in
      # This usually means the data coming back from FB didn't include an email address
      Airbrake.notify(FailedFacebookCreateError.new,
        :error_class => "FacebookLoginError",
        :error_messsage => "Facebook Login Error",
        :parameters => omniauth
      )
      if omniauth['extra']['raw_info']['email']
        raise FailedFacebookCreateError
      else
        raise NoEmailError
      end
    end
  end
end
