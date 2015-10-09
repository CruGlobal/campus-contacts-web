class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :token, :mobile_token
  belongs_to :user

  def self.user_from_mobile_facebook_token(facebook_token)
    user = Authentication.find_by(provider: 'facebook', mobile_token: facebook_token).try(:user)
    unless user
      fb_user = FbGraph2::User.new('me').authenticate(facebook_token).fetch.raw_attributes
      auth = Authentication.find_by(provider: 'facebook', uid: fb_user['id'])
      if auth
        auth.update_attributes(mobile_token: facebook_token)
        user = auth.user
      end
    end
    if user && user.person.present?
      user = nil if user.person.organizations.empty?
    else
      user = nil
    end
    user
  end
end
