class Authentication < ActiveRecord::Base
  belongs_to :user

  def self.user_from_mobile_facebook_token(facebook_token)
    user = Authentication.where(provider: 'facebook', mobile_token: facebook_token).first.try(:user)
    unless user
      fb_user = MiniFB.get(facebook_token, 'me')
      auth = Authentication.where(provider: 'facebook', uid: fb_user.id).first
      if auth
        auth.update_attributes(mobile_token: facebook_token)
        user = auth.user
      end
    end
    if user && user.person.organizations.empty?
      user = nil
    end
    user
  end
end
