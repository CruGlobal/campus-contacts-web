class SessionsController < Devise::SessionsController
  before_action :prepare_for_mobile
  skip_before_action :check_url
  skip_before_action :check_signature
  skip_before_action :check_all_signatures
  layout :pick_layout

  def new
    @survey = Survey.find(cookies[:survey_id]) if cookies[:survey_id].present?
    @title = nil
    if @survey
      @title = @survey.terminology
      if @survey.login_option == 2 || @survey.login_option == 3
        redirect_to "/s/#{cookies[:survey_id]}?nologin=true" and return
      end
    end

    # Show sign up page instead on log in if return_to action is set as leader_sign_in
    @show_sign_up = session.key?('return_to') &&
                    session['return_to'].is_a?(Hash) &&
                    session['return_to'][:action] == 'leader_sign_in'

    if user_signed_in?
      @facebook_logout = true
      sign_out
    end
    # Force HTML rendering
    render formats: [:html]
  end

  def destroy
    if session[:fb_token]
      split_token = session[:fb_token].split('|')
      fb_api_key = split_token[0]
      fb_session_key = split_token[1]
      session[:fb_token] = nil
    end

    if session[:relay_login].present?
      session.clear
      redirect_to 'https://signin.relaysso.org/cas/logout?service=' + CGI.escape(root_url)
    elsif session[:key_ticket].present?
      session.clear
      redirect_to 'https://thekey.me/cas/logout?service=' + CGI.escape(root_url)
    else
      flash[:facebook_logout] = true
      super
    end
  end

  protected

  def after_sign_out_path_for(_resource_or_scope)
    if mhub?
      case
      when params[:next]
        params[:next]
      when current_user
        user_root_path
      else
        root_path
      end
    else
      root_path
    end
  end

  def pick_layout
    mhub? ? 'mhub' : 'welcome'
  end
end
