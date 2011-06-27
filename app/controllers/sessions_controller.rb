class SessionsController < Devise::SessionsController
  def new
    render layout: 'login'
  end
  
  def destroy
    super
    session[:fb_token] = nil
  end
end