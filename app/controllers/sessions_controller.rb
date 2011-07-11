class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  def new
    logger.info cookies[:survey_mode].inspect
    if cookies[:survey_mode] == "1"
      render layout: 'plain'
    else
      render layout: 'splash'
    end
  end
  
  def destroy
    super
    session[:fb_token] = nil
  end
end