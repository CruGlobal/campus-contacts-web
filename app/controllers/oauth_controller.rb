class OauthController < ApplicationController
  require 'api_helper'
  include ApiHelper
  rescue_from Exception, with: :render_json_error    
  def authorize
      if current_user
        render :action=>"authorize"
      else
        redirect_to :action=>"login", :authorization=>oauth.authorization
      end
    end

    def grant
      head oauth.grant!(current_user.id)
    end

    def deny
      head oauth.deny!
    end
    
    def done
      raise AccountSetupRequiredError if (current_user.nil? || current_user.try(:person).nil? || current_user.person.primary_organization.nil?)
      raise IncorrectPermissionsError unless current_user.person.leader_in?(current_user.person.primary_organization)
      
      json_output = '{"status":"done", "code":"' + params[:code] + '"}'
      render json: json_output
    end
end
