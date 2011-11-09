class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  skip_before_filter :check_url
  layout :pick_layout
  
  def destroy
    session[:fb_token] = nil
    if mhub?
      render layout: 'mhub'
    else
      redirect_to after_sign_out_path_for('user')
    end
    sign_out
  end
  
  protected
  
  def pick_layout
    mhub? ? 'mhub' : 'login'
  end
end