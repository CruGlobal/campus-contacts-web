class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  def facebook
    begin
      facebook_login
      redirect_to @user ? after_sign_in_path_for(@user) : "/"
    rescue NoEmailError
      flash[:error] = t('sessions.new.login_no_email')
      redirect_to '/users/sign_in'
    rescue FailedFacebookCreateError
      flash[:error] = t('sessions.new.login_cannot_create_a_user')
      redirect_to '/users/sign_in'
    rescue FacebookDuplicateEmailError => e
      Airbrake.notify(e,
        :parameters => env["omniauth.auth"]
      )
      redirect_to '/welcome/duplicate'
    end
  end

  def facebook_mhub
    env["omniauth.auth"]['provider'] = 'facebook'
    begin
      if session[:person_id]
        logger.debug(session[:person_id])
        @person = Person.find(session[:person_id])
        unless @person.user
          @person = facebook_login(@person)
          session[:person_id] = @person.id
        end
      else
        facebook_login(nil, true)
      end

      if session[:person_id]
        @survey = Survey.find(session[:survey_id])
        render :template => "survey_responses/thanks", layout: 'mhub'
        return
      end

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

  def after_sign_out_path_for(resource_or_scope)
    params[:next] ? params[:next] : user_root_path
  end

  def facebook_login(person = nil, force = false)
    omniauth = env["omniauth.auth"]
    @user = User.find_for_facebook_oauth(omniauth, current_user, 0, force)
    session[:fb_token] = omniauth["credentials"]["token"]
    session["devise.facebook_data"] = omniauth

    person = @user.person.merge(person) if person

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

    person
  end
end
