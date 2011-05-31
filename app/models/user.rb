class User < ActiveRecord::Base
  set_table_name 'simplesecuritymanager_user'
  set_primary_key 'userID'
  
  has_one :person, :foreign_key => 'fk_ssmUserId'
  has_many :authentications
  has_many :sms_keywords
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :password
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    user = nil
    authentication = nil
#   signed_in_resource = nil

    if authentication = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
      authentication.update_attribute(:token, access_token['credentials']['token'])
      user = authentication.user
    else
      user = signed_in_resource || User.find(:first, :conditions => ["username = ? or username = ?", data['email'], data['username']])
      user = User.create!(:email => data["email"], :password => Devise.friendly_token[0,20]) if user.nil?
      user.save
    
      authentication = user.authentications.create(:provider => 'facebook', :uid => access_token['uid'], :token => access_token['credentials']['token'])
    end

    if user.person 
      user.person.update_from_facebook(data, authentication).inspect
    else
      user.person = Person.create_from_facebook(data, authentication)
    end
    user
  end 
  
  def email=(email)
    self.username = email
    self[:email] = email
  end
  
  def email
    username
  end
  
  def to_s
    person ? person.to_s : email
  end
  
  def merge(other)
    User.transaction do
      person.merge(other.person)
      
      # Authentications
      other.authentications.collect {|oa| oa.update_attribute(:user_id, id)}
      
      # Sms Keywords
      other.sms_keywords.collect {|oa| oa.update_attribute(:user_id, id)}
      
      MergeAudit.create!(:mergeable => self, :merge_looser => other)
      other.destroy
    end
  end
end
