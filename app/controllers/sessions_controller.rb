class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  skip_before_filter :check_url
  skip_before_filter :authenticate_user!, only: :new
  
  def new
    # if cookies[:survey_mode] == "1"
      render layout: 'plain'
    # else
      # render layout: 'splash'
    # end
  rescue AbstractController::DoubleRenderError
  end
  
  def destroy
    session[:fb_token] = nil
    if mhub?
      render layout: 'plain'
    else
      redirect_to after_sign_out_path_for('user')
    end
    sign_out
  end
end