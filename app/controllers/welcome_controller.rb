class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :tutorials, :tour, :terms, :privacy, :duplicate,
                                                 :request_access, :requested_access, :thank_you]
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

  def request_access
    @request_access = RequestAccess.new
    render layout: 'welcome'
  end

  def requested_access
    @request_access = RequestAccess.new(params[:request_access])
    if @request_access.valid?
      person = Person.new_from_params(@request_access.person_params)
      organization = Organization.new(@request_access.organization_params.merge(status: 'requested',
                                                                                terminology: 'Organization'))
      if person.save && organization.save
        organization.add_admin(person) unless organization.admins.present?
        redirect_to thank_you_path
        return
      end
    end
    render :request_access, layout: 'welcome'
  end

  def thank_you
    @request_access = true # Activate the request_access menu item
    render layout: 'welcome'
  end

  def duplicate
    render layout: 'splash'
  end
end
