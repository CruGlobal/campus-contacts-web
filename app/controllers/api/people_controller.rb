class Api::PeopleController < ApiController
  oauth_required scope: "userinfo"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header

  def show_1
    json_output = get_people.collect {|u| u.to_hash(@organization).slice(*@valid_fields) unless u.nil?}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end

  def show_2
    json_output = @api_json_header
    json_output[:people] = get_people.collect {|u| u.to_hash(@organization).slice(*@valid_fields) unless u.nil?}
    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON::pretty_generate(json_output)
    render json: final_output
  end

  def leaders_2
    output = @api_json_header
    output[:leaders] = @organization.leaders.collect{|l| l.to_hash_micro_leader}
    render json: output
  end
end
