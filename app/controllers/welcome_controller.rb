class WelcomeController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index, :tour, :terms, :privacy]
  skip_before_filter :check_url, only: [:terms, :privacy]
  def index
    if user_signed_in?
      redirect_to user_root_path and return
    end
    render layout: 'splash'#, stream: true
  end
  
  def wizard
    session[:wizard] = nil
    case params[:step]
    when 'keyword'
      @redirect = true unless current_organization
    when 'survey'
      @redirect = true unless current_organization && current_organization.self_and_children_surveys.present?
    when 'leaders'
      @redirect = true unless current_organization
    end
    if @redirect
      redirect_to wizard_path and return
    end
  end
  
  def tour
    render layout: 'splash'
  end
  
  def terms
    render layout: mhub? ? 'mhub' : 'splash'
  end
  
  def privacy
    render layout: mhub? ? 'mhub' : 'splash'
  end
end
