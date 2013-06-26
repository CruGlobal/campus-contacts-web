class Apis::V4::BaseController < ApplicationController
  skip_before_filter :set_login_cookie
  skip_before_filter :check_su
  skip_before_filter :check_valid_subdomain
  skip_before_filter :set_locale
  skip_before_filter :check_url

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  protected

  def authenticate_user!
    unless params[:secret] || oauth_access_token || facebook_token
      render json: {errors: ["You need to pass in your Organization's API secret or a user's oauth or facebook token."]},
             status: :unauthorized,
             callback: params[:callback]
      return false
    end

    if facebook_token
      begin
        unless @current_user = Authentication.where(provider: 'facebook', mobile_token: facebook_token).first.try(:user)
          fb_user = MiniFB.get(facebook_token, 'me')
          auth = Authentication.where(provider: 'facebook', uid: fb_user.id).first
          if auth
            auth.update_attributes(mobile_token: facebook_token)
            @current_user = auth.user
          else
            render json: {errors: ["The person corresponding to that token has never logged into the web interface"], code: 'user_not_found'},
                   status: :unauthorized,
                   callback: params[:callback]
            return false
          end
        end
      rescue MiniFB::FaceBookError => e
        render json: {errors: ["The facebook token you passed is invalid"], code: 'invalid_facebook_token'},
               status: :unauthorized,
               callback: params[:callback]
        return false
      end
    end

    if oauth_access_token && !current_user
      render json: {errors: ["The oauth you sent over didn't match a user or organization on MissionHub"]},
             status: :unauthorized,
             callback: params[:callback]
      return false
    end

    if params[:secret] && !current_organization
      render json: {errors: ["The secret you sent over didn't match a user or organization on MissionHub"]},
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

    current_organization #ensure the current organization is initialized
  end

  def current_user
    unless @current_user
      if oauth_access_token
        @current_user = User.from_access_token(oauth_access_token)
      elsif params[:secret]
        @current_user = current_organization.parent_organization_admins.first.try(:user)
      end
    end
    @current_user
  end

  def current_organization
    unless @current_organization
      if params[:secret]
        api_org = Rack::OAuth2::Server::Client.find_by_secret(params[:secret]).try(:organization)
        if api_org
          @current_organization = params[:organization_id] ? api_org.subtree.find(params[:organization_id]) : api_org
        end
      elsif current_user
        primary_organization = current_user.person.primary_organization
        @current_organization = params[:organization_id] ? current_user.person.all_organization_and_children.find(params[:organization_id]) : primary_organization
      end
    end
    @current_organization
  end

  def oauth_access_token
    @oauth_access_token ||= (params[:access_token] || oauth_access_token_from_header)
  end

  def facebook_token
    @facebook_token ||= (params[:facebook_token] || facebook_token_from_header)
  end

  # grabs access_token from header if one is present
  def oauth_access_token_from_header
    auth_header = request.env["HTTP_AUTHORIZATION"]||""
    match = auth_header.match(/^token\s(.*)/) || auth_header.match(/^Bearer\s(.*)/)
    return match[1] if match.present?
    false
  end

  # grabs facebook token from header if one is present
  def facebook_token_from_header
    auth_header = request.env["HTTP_AUTHORIZATION"]||""
    match = auth_header.match(/^Facebook\s(.*)/)
    return match[1] if match.present?
    false
  end

  def render_404
    render nothing: true, status: 404
  end

  def add_includes_and_order(resource, options = {})
    # eager loading is a waste of time if the 'since' parameter is passed
    unless params[:since]
      available_includes.each do |rel|
        resource = resource.includes(rel.to_sym) if includes.include?(rel.to_s)
      end
    end
    resource = resource.where("#{resource.table.name}.updated_at > ?", Time.at(params[:since].to_i)) if params[:since].to_i > 0
    resource = resource.limit(params[:limit]) if params[:limit]
    resource = resource.offset(params[:offset]) if params[:offset]
    resource = resource.order(options[:order]) if options[:order]
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

