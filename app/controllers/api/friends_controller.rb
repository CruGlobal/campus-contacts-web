class Api::FriendsController < ApiController
  oauth_required scope: "userinfo"
  
  def show_1
    json_output = get_people.collect { |u| Friend.get_friends_from_person_id(u.id, @valid_fields)}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
end