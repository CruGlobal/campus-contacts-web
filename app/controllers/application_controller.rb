class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :prepare_for_mobile
  protect_from_forgery  

  protected
  
  def after_sign_in_path_for(resource)
    if request.session[:return_to].is_a? String
      [request.session[:return_to], request.session[:return_params].to_query].join("?")
    elsif request.session[:return_to].is_a? Hash
      request.session[:return_to].merge!(request.session[:return_params])
    else
      super
    end
  end
  
  def mobile_device?
    return true # treat everything as mobile while we build views

    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end
end
