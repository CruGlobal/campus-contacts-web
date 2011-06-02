class Api::UserController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  # enable detailed logging
  $dev_logger = nil
  $dev_logger = MHDevLogger::Logger.new(Rails.root.to_s+'/log/dev.log')
  $dev_logger.level = Logger::DEBUG
  
  def friends_1
    valid_fields = valid_request_with_rescue(request)
    if valid_fields.is_a? Hash
      friends = valid_fields
    else #friends = Friend.get_friends_from_person_id(get_users.person.personID, valid_fields)
      friends = get_users.collect { |u| Friend.get_friends_from_person_id(u.person.personID, valid_fields)}
    end
    render :json => JSON::pretty_generate(friends)
  end
  
  def user_1
    valid_fields = valid_request_with_rescue(request)
    if valid_fields.is_a? Hash
       users = valid_fields
    else users = get_users.collect {|u| u.person.to_hash.slice(*valid_fields)}
    end
    render :json => JSON::pretty_generate(users)
  end
  
  def schools_1
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :json => result.to_json
  end  
end