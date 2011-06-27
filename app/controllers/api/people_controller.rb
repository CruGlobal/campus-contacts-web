class Api::PeopleController < ApiController
  #raise 'hey'
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  oauth_required scope: "userinfo"
  rescue_from Exception, with: :render_json_error
  
  def show_1
    valid_fields = valid_request?(request)
    json_output = get_people.collect {|u| u.to_hash(@organization).slice(*@valid_fields) unless u.nil?}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
end