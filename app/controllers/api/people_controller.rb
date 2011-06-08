class Api::PeopleController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def show_1
    valid_fields = valid_request?(request)
    if valid_fields.is_a? Hash
       people = valid_fields
       #get_users actually returns person objects!
    else people = get_people.collect {|u| u.to_hash.slice(*valid_fields) unless u.nil?}
    end
    render :json => JSON::pretty_generate(people)
  end
  
  def schools_1
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :json => result.to_json
  end  
end