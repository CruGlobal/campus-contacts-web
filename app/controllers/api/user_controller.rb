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
     valid_fields = valid_request?(request)
     if params[:id]=="me"
       user_id = oauth.identity
     else
       user_id = params[:id]
     end

     user = User.find_by_userID(user_id)
     person = user.person
     @friends_json = []
     @friends = Friend.where("person_id = ?",person.personID)
     @friends.each do |x|
       @friend = { :uid => x.uid, :name => x.name, :provider => x.provider}
       @friends_json.push(@friend)
     end
     render :json => @friends_json
  end
  
  def user_1
    #valid_request? ensures that their request is a legal api request.  if error, spits out an error message
    valid_fields = valid_request?(request)
    if params[:id]=="me"
      user_id = oauth.identity
    else
      user_id = params[:id]
    end
    user = User.find_by_userID(user_id)
    raise ApiErrors::NoDataReturned unless user
    
    person = user.person
    
    api_call = {}
    #get their most recently authenticated facebook authorization entry
    @fb_id = user.authentications.where(:provider => "facebook").order("updated_at DESC").first.uid
    valid_fields.each do |x|
      case x
        when "id"
          api_call[x] = user.userID
        when "name"
          api_call[x] = person.to_s
        when "first_name"
          api_call[x] = person.firstName
        when "last_name"
          api_call[x] = person.lastName
        when "gender" 
          api_call[x] = person.gender
        when "locale"
          api_call[x] = user.locale ? user.locale : ""
        when "lacation"
          api_call[x] = ""
        when "fb_id"
          api_call[x] = @fb_id
        when "birthday"
          api_call[x] = person.birth_date
        when "picture"
          api_call[x] = "http://graph.facebook.com/#{@fb_id}/picture"
        when "friends"
          api_call[x] = ""
        when "interests"
          api_call[x] = ""
      end
    end
    render :json => api_call.to_json
  end
  
  def schools
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :text => result.to_json
  end  
end