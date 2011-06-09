class OauthController < ApplicationController
  def authorize
      if current_user
        render :action=>"authorize"
      else
        redirect_to :action=>"login", :authorization=>oauth.authorization
      end
    end

    def grant
      head oauth.grant!(current_user.person.id)
    end

    def deny
      head oauth.deny!
    end
end
