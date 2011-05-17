class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  oauth_required :except => :getuser
  
  def getuser
    user = User.find_by_userID(oauth.identity)# if oauth.authenticated?
    #raise user.to_json
    render :text => user.to_json
  end
  
  def getschools
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :text => result.to_json
  end
  
end
