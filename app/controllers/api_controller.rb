class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  oauth_required :except => getuser
  def getuser
    user = User.find_by_userID(oauth.identity)# if oauth.authenticated?
    #raise user.to_json
    render :text => user.to_json
  end
  
end
