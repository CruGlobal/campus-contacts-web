class SessionsController < Devise::SessionsController
  def new
    render layout: 'splash'
  end
  
  def destroy
    super
    session[:fb_token] = nil
  end
end