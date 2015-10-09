class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :tutorials, :tour, :terms, :privacy, :duplicate]
  skip_before_action :check_url, only: [:terms, :privacy]
  skip_before_action :check_all_signatures, only: [:index]

  def index
    redirect_to(user_root_path) && return if user_signed_in?
    render layout: 'welcome' # , stream: true
  end

  def tutorials
    render layout: 'splash'
  end

  def wizard
    session[:wizard] = nil
    case params[:step]
    when 'keyword'
      @redirect = true unless current_organization && current_organization.self_and_children_surveys.present?
    when 'survey'
      @redirect = true unless current_organization
    when 'leaders'
      @redirect = true unless current_organization
    end
    redirect_to(wizard_path) && return if @redirect
  end

  def tour
    render layout: 'splash'
  end

  def terms
    render layout: mhub? ? 'mhub' : 'welcome'
  end

  def privacy
    render layout: mhub? ? 'mhub' : 'welcome'
  end

  def duplicate
    render layout: 'splash'
  end
end
