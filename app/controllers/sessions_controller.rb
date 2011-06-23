class SessionsController < Devise::SessionsController
  def new
    render :layout => 'login'
  end
end