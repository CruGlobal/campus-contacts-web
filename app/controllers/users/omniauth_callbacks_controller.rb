class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :authenticate_user!
  skip_before_action :check_url
  def facebook
    facebook_login
    redirect_to @user ? after_sign_in_path_for(@user) : '/'
  rescue NoEmailError
    flash[:error] = t('sessions.new.login_no_email')
    redirect_to '/users/sign_in'
  rescue FailedFacebookCreateError
    flash[:error] = t('sessions.new.login_cannot_create_a_user')
    redirect_to '/users/sign_in'
  rescue FacebookDuplicateEmailError => e
    Rollbar.error(e,
                  parameters: env['omniauth.auth']
                 )
    redirect_to '/welcome/duplicate'
  end

  def facebook_mhub
    env['omniauth.auth']['provider'] = 'facebook'
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
        render template: 'survey_responses/thanks', layout: 'mhub'
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

  def relay
    if user_signed_in?
      redirect_to root_path
    else
      begin
        @user = User.find_for_cas_oauth(request.env['omniauth.auth'])
        if @user.present?
          sign_in(@user)
          session[:relay_login] = true
          redirect_to root_path
        else
          fail NoEmailError
        end
      rescue NotAllowedToUseCASError
        flash[:error] = t('sessions.new.not_allowed_to_use_cas')
        redirect_to '/users/sign_in'
      rescue NoEmailError
        flash[:error] = t('sessions.new.login_no_email')
        redirect_to '/users/sign_in'
      end
    end
  end

  def key
    if user_signed_in?
      redirect_to root_path
    else
      omniauth = request.env['omniauth.auth']
      begin
        if ticket = omniauth['credentials']['ticket']
          @user = User.find_for_key_oauth(omniauth)
          if @user.present?
            sign_in(@user)
            session[:key_ticket] = ticket
            redirect_to root_path
          else
            fail NoEmailError
          end
        else
          fail NoTicketError
        end
      rescue NoTicketError
        flash[:error] = t('sessions.new.no_ticket_error')
        redirect_to "#{root_url}sign_in"
      rescue NotAllowedToUseKeyError
        flash[:error] = t('sessions.new.not_allowed_to_use_key')
        redirect_to "#{root_url}sign_in"
      rescue NoEmailError
        flash[:error] = t('sessions.new.login_no_email')
        redirect_to "#{root_url}sign_in"
      end
    end
  end

  protected

  def after_sign_out_path_for(_resource_or_scope)
    params[:next] ? params[:next] : user_root_path
  end

  def user_from_token
    return unless session[:user_with_token].present?
    User.find_by(id: session[:user_with_token])
  end

  def facebook_login(person = nil, force = false)
    omniauth = env['omniauth.auth']
    @user = User.find_for_facebook_oauth(omniauth, current_user || user_from_token, 0, force)
    session[:fb_token] = omniauth['credentials']['token']
    session['devise.facebook_data'] = omniauth

    person = @user.person.merge(person) if person

    if @user && @user.persisted?
      session.delete(:message)
      sign_in(@user)
    else
      # There was a problem logging this person in
      # This usually means the data coming back from FB didn't include an email address
      Rollbar.error(FailedFacebookCreateError.new,
                    error_class: 'FacebookLoginError',
                    error_messsage: 'Facebook Login Error',
                    parameters: omniauth
                   )
      if omniauth['extra']['raw_info']['email']
        fail FailedFacebookCreateError
      else
        fail NoEmailError
      end
    end
    person
  end
end
