class Api::FriendsController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def show_1
    valid_fields = valid_request_with_rescue(request)
    if valid_fields.is_a? Hash
      friends = valid_fields  #print out the exception
    else
      friends = get_users.collect { |u| Friend.get_friends_from_person_id(u.person.personID, valid_fields)}
    end
    render :json => JSON::pretty_generate(friends)
  end
end