class OauthController < ApplicationController
  require 'api_helper'
  include ApiHelper
    
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
      json_output = '{"error": {"message": "You do not have a leader role in MissionHub.", "code": "25"}}'
      if (!current_user.nil? && !current_user.try(:person).nil? && !current_user.person.primary_organization.nil?)
        json_output = '{"status":"done", "code":"' + params[:code] + '"}' if current_user.person.leader_in?(current_user.person.primary_organization)
      end
      render json: json_output
    end
end
