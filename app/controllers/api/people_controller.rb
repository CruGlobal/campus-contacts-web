class Api::PeopleController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
  oauth_required :scope => "userinfo"
  rescue_from Exception, :with => :render_json_error
  
  def show_1
    valid_fields = valid_request?(request)
    org = get_organization
    people = get_people.collect {|u| u.to_hash(org).slice(*@valid_fields) unless u.nil?}
    render :json => JSON::pretty_generate(people)
  end
  
  def schools_1
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :json => result.to_json
  end  
end