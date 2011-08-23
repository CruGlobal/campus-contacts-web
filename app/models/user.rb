class User < ActiveRecord::Base
  begin
    include Ccc::SimplesecuritymanagerUser
  rescue LoadError; end
  WIZARD_STEPS = %w[welcome verify keyword survey leaders]
  set_table_name 'simplesecuritymanager_user'
  set_primary_key 'userID'
  
  has_one :person, foreign_key: 'fk_ssmUserId'
  has_many :authentications
  has_many :sms_keywords
  has_many :access_tokens, :class_name => "Rack::OAuth2::Server::AccessToken", :foreign_key => "identity"
  has_many :access_grants, :class_name => "Rack::OAuth2::Server::AccessGrant", :foreign_key => "identity"
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :password
  # alias_method :find_by_userID, :find_by_id
  def self.find_by_id(*args)
    find_by_userID(args)
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token['extra']['user_hash']
    return nil unless data["email"].present?
    user = nil
    authentication = nil
    
    transaction do
      authentication = Authentication.find_by_provider_and_uid(access_token['provider'], access_token['uid'])
      #Let's also ensure that someone who has an authentication also has a user.  If not, delete the authentication and make a user
      if authentication && !authentication.user.nil?
        authentication.update_attribute(:token, access_token['credentials']['token'])
        user = authentication.user
      else
        authentication.delete if authentication
        user = signed_in_resource || User.where(["username = ? or username = ?", data['email'], data['username']]).first
        unless user
          begin
            user = create!(email: data["email"], password: Devise.friendly_token[0,20]) 
          rescue 
            user = find_by_email(data['email'])
            raise data.inspect unless user
          end
        end
        user.save
        authentication = user.authentications.create(provider: 'facebook', uid: access_token['uid'], token: access_token['credentials']['token'])
      end
    
      if user.person 
        user.person.update_from_facebook(data, authentication)
      else
        user.person = Person.create_from_facebook(data, authentication)
      end
    end
    user
  end 
  
  def next_wizard_step(org)
    case 
    when org.nil? then 'verify'
    when org && org.self_and_children_keywords.blank? then 'keyword'
    when org && org.self_and_children_questions.blank? then 'survey'
    end
  end
  
  def email=(email)
    self.username = email
    self[:email] = email
  end
  
  def email
    username
  end
  
  def to_s
    person ? person.to_s : (email || username).to_s
  end
  
  def name_with_keyword_count
    "#{to_s} (#{sms_keywords.count})"
  end
  
  rails_admin do
    # object_label_method {:name_with_keyword_count}
    visible false
    list do
      field :username
    end
  end
  
  def merge(other)
    User.transaction do
      person.merge(other.person) if person

      # Authentications
      other.authentications.collect {|oa| oa.update_attribute(:user_id, id)}
      
      # Oauth
      other.access_tokens.collect {|at| at.update_attribute(:identity, id)}
      other.access_grants.collect {|ag| ag.update_attribute(:identity, id)}
      
      # Sms Keywords
      other.sms_keywords.collect {|oa| oa.update_attribute(:user_id, id)}
      
      super
      
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
    end
  end
end
