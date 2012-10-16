require 'errors/no_email_error'
require 'errors/failed_facebook_create_error'
require 'errors/facebook_duplicate_email_error'
class User < ActiveRecord::Base
  WIZARD_STEPS = %w[welcome verify keyword survey leaders]
  self.table_name = 'simplesecuritymanager_user'
  self.primary_key = 'userID'
  
  store :settings, accessors: [:primary_organization_id]
  
  has_one :person, foreign_key: 'fk_ssmUserId'
  has_many :authentications
  has_many :sms_keywords
  has_many :access_tokens, :class_name => "Rack::OAuth2::Server::AccessToken", :foreign_key => "identity"
  has_many :access_grants, :class_name => "Rack::OAuth2::Server::AccessGrant", :foreign_key => "identity"
  has_many :saved_contact_searches
  has_many :imports
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :remember_me, :password, :username
  # alias_method :find_by_userID, :find_by_id
  def self.find_by_id(*args)
    find_by_userID(args)
  end
  
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil, attempts = 0, force = false)
    data = access_token['extra']['raw_info']
    unless data["email"].present?
      raise NoEmailError, access_token['extra'].inspect
    end
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
        user = signed_in_resource || User.where(username: data['email']).first
        # If we don't have a user with a matching email username, look for a match from email_addresses table
        # with the same first and last name
        unless user
          if existing = Person.find_from_facebook(data)
            if existing.lastName.strip == data['last_name'].strip && 
               (existing.firstName.to_s.strip == data['first_name'].strip || existing.preferredName.to_s.strip == data['first_name'].strip)
              user = existing.user
            else
              # If first and last name don't match, there's probably some bad data
              # If this person is logging in to fill out a survey, we want to handle this gracefully
              if force
                user = existing.user
              else
                raise FacebookDuplicateEmailError
              end
            end
          end
        end

        # If all else fails, create a user
        unless user
          begin
            user = create!(email: data["email"], password: Devise.friendly_token[0,20]) 
          rescue 
            sleep(1)
            user = find_by_email(data['email']) || find_by_username(data['email']) # create!(email: data["email"], password: Devise.friendly_token[0,20]) 
            if !user && attempts < 3
              find_for_facebook_oauth(access_token, signed_in_resource, attempts + 1)
            else
              raise FailedFacebookCreateError, data.inspect 
            end
          end
        end
        user.save
        begin
          authentication = user.authentications.create(provider: 'facebook', uid: access_token['uid'], token: access_token['credentials']['token'])
        rescue; end
      end
    
      if user.person 
        user.person.update_from_facebook(data, authentication)
      else
        existing = Person.find_from_facebook(data)
        if existing && existing.user
          existing.user.merge(user)
          user = existing.user
        else
          user.person = existing || Person.create_from_facebook(data, authentication)
        end
      end
    end
    user
  end 
  
  def next_wizard_step(org)
    case 
    when org.nil? then ''
    when org && org.self_and_children_surveys.blank? then 'survey'
    when org && org.self_and_children_keywords.blank? then 'keyword'
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
  
  def merge(other)
    User.connection.execute('SET foreign_key_checks = 0')
    User.transaction do
      person.merge(other.person) if person

      # Authentications
      other.authentications.collect {|oa| oa.update_attribute(:user_id, id)}
      
      # Oauth
      other.access_tokens.collect {|at| at.update_attribute(:identity, id)}
      other.access_grants.collect {|ag| ag.update_attribute(:identity, id)}
      
      # Sms Keywords
      other.sms_keywords.collect {|oa| oa.update_attribute(:user_id, id)}
      
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
    end
    User.connection.execute('SET foreign_key_checks = 1')
  end
  
  def has_role?(role_id, organization)
    OrganizationalRole.where(role_id: role_id, organization_id: organization.id).first.present?
  end
end
