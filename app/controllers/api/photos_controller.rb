class Api::PhotosController < ApiController
  oauth_required scope: "userinfo"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header

  def create_2
    person = Person.find(params[:contact_id])
    person.person_photo = PersonPhoto.create(image: params[:image])
    
    render nothing: true
  end
  
end