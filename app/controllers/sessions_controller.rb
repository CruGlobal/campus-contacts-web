class SessionsController < Devise::SessionsController
  before_filter :prepare_for_mobile
  def new
    render layout: 'splash'
  end
  
  def destroy
    super
    session[:fb_token] = nil
  end
end