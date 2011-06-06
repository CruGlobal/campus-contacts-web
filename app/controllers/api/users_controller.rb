class Api::UsersController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def show_1
    valid_fields = valid_request?(request)
    if valid_fields.is_a? Hash
       users = valid_fields
    else users = get_users.collect {|u| u.person.to_hash.slice(*valid_fields) unless u.person.nil?}
    end
    render :json => JSON::pretty_generate(users)
  end
  
  def schools_1
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :json => result.to_json
  end  
end