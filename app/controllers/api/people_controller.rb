class Api::PeopleController < ApiController
  oauth_required scope: "userinfo"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
  def show_1
    json_output = get_people.collect {|u| u.to_hash(@organization).slice(*@valid_fields) unless u.nil?}    
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
end