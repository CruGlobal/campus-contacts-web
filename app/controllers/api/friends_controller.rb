class Api::FriendsController < ApiController
  require 'api_helper'
  include ApiHelper 
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
  skip_before_filter :authenticate_user!
  oauth_required :scope => "userinfo"
  rescue_from Exception, :with => :render_json_error
  
  def show_1
    friends = get_people.collect { |u| Friend.get_friends_from_person_id(u.id, @valid_fields)}
    render :json => JSON::pretty_generate(friends)
  end
end