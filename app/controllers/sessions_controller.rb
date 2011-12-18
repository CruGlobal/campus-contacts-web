class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  skip_before_filter :check_url
  layout :pick_layout
  
  def destroy
    if session[:fb_token]
      split_token = session[:fb_token].split("|")
      fb_api_key = split_token[0]
      fb_session_key = split_token[1]
      session[:fb_token] = nil
    end
    super
  end
  
  protected
  
  def after_sign_out_path_for(resource_or_scope)
    params[:next] ? params[:next] : root_url
  end
  
  def pick_layout
    mhub? ? 'mhub' : 'login'
  end
end