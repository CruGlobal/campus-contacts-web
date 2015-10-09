class Api::FriendsController < ApiController
  oauth_required scope: 'userinfo'
  before_action :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization

  def show_1
    json_output = get_people.collect do |p|
      friends = Friend.get_friends_from_person_id(p).collect(&:to_hash)
      hash = { person: { name: p.to_s, id: p.id }, friends: friends }
    end

    final_output = Rails.env.production? ? JSON.fast_generate(json_output) : JSON.pretty_generate(json_output)
    render json: final_output
  end
end
