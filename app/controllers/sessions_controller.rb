class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  skip_before_filter :check_url
  
  def new
    # if cookies[:survey_mode] == "1"
      render layout: 'plain'
    # else
      # render layout: 'splash'
    # end
  end
  
  def destroy
    super
    session[:fb_token] = nil
  end
end