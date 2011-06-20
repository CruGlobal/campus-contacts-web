class Api::FriendsController < ApiController
  require 'api_helper'
  include ApiHelper 
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
  skip_before_filter :authenticate_user!
  oauth_required :scope => "userinfo"
  rescue_from Exception, :with => :render_json_error
  
  def show_1
    json_output = get_people.collect { |u| Friend.get_friends_from_person_id(u.id, @valid_fields)}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render :json => final_output
  end
end