require 'errors/no_email_error'
require 'errors/failed_facebook_create_error'
require 'errors/facebook_duplicate_email_error'
require 'errors/not_allowed_to_use_cas_error'
require 'errors/not_allowed_to_use_key_error'
require 'errors/no_ticket_error'
class User < ActiveRecord::Base
  has_paper_trail on: [:destroy],
                  meta: { person_id: :person_id }

  WIZARD_STEPS = %w(welcome verify keyword survey leaders)
  self.primary_key = 'id'

  store :settings, accessors: [:primary_organization_id, :time_zone]

  has_one :person, foreign_key: 'user_id'
  has_one :super_admin
  has_many :authentications
  has_many :sms_keywords
  has_many :access_tokens, class_name: 'Rack::OAuth2::Server::AccessToken', foreign_key: 'identity'
  has_many :access_grants, class_name: 'Rack::OAuth2::Server::AccessGrant', foreign_key: 'identity'
  has_many :saved_contact_searches
  has_many :imports
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :remember_me, :password, :username, :remember_token_expires_at

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  def self.from_access_token(token)
    if access_token = Rack::OAuth2::Server::AccessToken.find_by_code(token)
      return User.find(access_token.identity)
    end
  end

  def self.find_for_cas_oauth(cas_info)
    data = cas_info['extra']
    if data['username'].blank?
      fail NoEmailError
    else
      username = data['username']
      person = Person.find_existing_person_by_email(username)
      if person.present?
        user = person.user
        unless user
          begin
            user = User.where(username: username).first_or_initialize
            user.password = Devise.friendly_token[0, 20] unless user.id.present?
            user.save
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end
      else
        fail NotAllowedToUseCASError
      end

      return user
    end
  end

  def self.find_for_key_oauth(key_info)
    data = key_info['extra']
    if data['user'].blank?
      fail NoEmailError
    else
      email = data['user']
      person = Person.find_existing_person_by_email(email)
      if person.present?
        user = person.user
        unless user
          begin
            user = User.where(username: email).first_or_initialize
            user.password = Devise.friendly_token[0, 20] unless user.id.present?
            user.save
          rescue ActiveRecord::RecordNotUnique
            retry
          end
        end
      else
        fail NotAllowedToUseKeyError
      end

      return user
    end
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource = nil, attempts = 0, force = false)
    data = access_token['extra']['raw_info']
    person = Person.find_from_facebook(data)

    email = data['email'] || signed_in_resource.try(:username)
    last_name = data['last_name']
    first_name = data['first_name']

    provider = access_token['provider']
    uid = access_token['uid']
    token = access_token['credentials']['token']

    if email.blank? && person.nil?
      fail NoEmailError, access_token['extra'].inspect
    end

    user = nil
    authentication = nil

    transaction do
      authentication = Authentication.find_by_provider_and_uid(provider, uid)

      # Let's also ensure that someone who has an authentication also has a user.  If not, delete the authentication and make a user
      if authentication && !authentication.user.nil?
        authentication.update_attribute(:token, token)
        user = authentication.user
      else
        authentication.delete if authentication
        user = signed_in_resource || User.find_by(username: email)
        # If we don't have a user with a matching email username, look for a match from email_addresses table
        # with the same first and last name

        if user.nil? && person.present?
          unless force
            if person.last_name.try(:strip) != last_name.strip || person.first_name.try(:strip) != first_name.strip
              person.last_name = last_name.strip
              person.first_name = first_name.strip
              person.save
            end
          end
          user = person.user
        end

        # If all else fails, create a user
        unless user
          begin
            user = User.where(username: email).first_or_initialize
            user.password = Devise.friendly_token[0, 20] unless user.id.present?
            user.save
          rescue
            sleep(1)
            user = find_by_username(email)
            if !user && attempts < 3
              find_for_facebook_oauth(access_token, signed_in_resource, attempts + 1)
            else
              raise FailedFacebookCreateError, data.inspect
            end
          end
        end
        user.save
        begin
          authentication = user.authentications.create(provider: provider, uid: uid, token: token)
        rescue; end
      end

      if user.person
        user.person.update_from_facebook(data, authentication)
      else
        if person && person.user
          person.user.merge(user)
          user = person.user
        else
          user.person = person || Person.create_from_facebook(data, authentication)
        end
      end
    end
    user.person.add_email(email)
    user.person.touch
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
  end

  def email
    username
  end

  def to_s
    person ? person.to_s : username.to_s
  end

  def name_with_keyword_count
    "#{self} (#{sms_keywords.count})"
  end

  def merge(other)
    User.connection.execute('SET foreign_key_checks = 0')
    User.transaction do
      person.merge(other.person) if person

      # Authentications
      other.authentications.collect { |oa| oa.update_attribute(:user_id, id) }

      # Oauth
      other.access_tokens.collect { |at| at.update_attribute(:identity, id) }
      other.access_grants.collect { |ag| ag.update_attribute(:identity, id) }

      # Sms Keywords
      other.sms_keywords.collect { |oa| oa.update_attribute(:user_id, id) }

      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
    end
    User.connection.execute('SET foreign_key_checks = 1')
  end

  def has_permission?(permission_id, organization)
    person && OrganizationalPermission.find_by(permission_id: permission_id, organization_id: organization.id, person_id: person.id).present?
  end

  def person_id
    person.try(:id)
  end

  # To hook the Devise validation of email field.
  # Since we've removed the the email column from the database, we have to put these methods
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def generate_new_token
    token = SecureRandom.hex(12)
    self.remember_token = token
    self.remember_token_expires_at = 1.month.from_now
    save(validate: false)
  end
end
