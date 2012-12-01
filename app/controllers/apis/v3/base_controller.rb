class Apis::V3::BaseController < ApplicationController
  skip_before_filter :set_login_cookie
  skip_before_filter :check_su
  skip_before_filter :check_valid_subdomain
  skip_before_filter :set_locale
  skip_before_filter :check_url

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protected

  def authenticate_user!
    unless params[:secret]
      render json: {errors: ["You need to pass in the your Organization's API secret"]},
        status: :unauthorized,
        callback: params[:callback]
      return false
    end
    unless current_organization
      render json: {errors: ["The secret you sent over didn't match an Organization on MissionHub"]},
        status: :unauthorized,
        callback: params[:callback]
      return false
    end
    unless current_user
      render json: {errors: ["The organization associated with this API secret must have at least one admin, or you must pass in an oauth access token for a user with access to this org."]},
        status: :unauthorized,
        callback: params[:callback]
      return false
    end
  end

  def current_user
    unless @current_user
      if oauth_access_token
        @current_user = User.from_access_token(oauth_access_token)
      else
        @current_user = current_organization.admins.first.try(:user)
      end
    end
    @current_user
  end

  def current_organization
    unless @current_organization
      api_org = Rack::OAuth2::Server::Client.find_by_secret(params[:secret]).try(:organization)
      @current_organization = params[:organization_id] ? api_org.subtree.find(params[:organization_id]) : api_org
    end
    @current_organization
  end

  def oauth_access_token
    oauth_access_token ||= (params[:access_token] || oauth_access_token_from_header)
  end


  # grabs access_token from header if one is present
  def oauth_access_token_from_header
    auth_header = request.env["HTTP_AUTHORIZATION"]||""
    match       = auth_header.match(/^token\s(.*)/) || auth_header.match(/^Bearer\s(.*)/)
    return match[1] if match.present?
    false
  end

  def render_404
    render nothing: true, status: 404
  end

  def add_includes_and_order(resource, options = {})
    available_includes.each do |rel|
      resource = resource.includes(rel.to_sym) if includes.include?(rel.to_s)
    end
    resource = resource.limit(params[:limit]) if params[:limit]
    resource = resource.offset(params[:offset]) if params[:offset]
    resource.order(options[:order]) if options[:order]
    resource
  end

  # let the api use add additional relationships to this call
  def includes
    @includes ||= params[:include].to_s.split(',')
  end

  # Each controller should override this method
  def available_includes
    []
  end

end

