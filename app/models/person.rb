require 'vpim/vcard'
require 'vpim/book'
require 'ccc/person'

class Person < ActiveRecord::Base
  include Ccc::Person
  set_table_name 'ministry_person'
  set_primary_key 'personID'

  belongs_to :user, class_name: 'User', foreign_key: 'fk_ssmUserId'
  has_many :phone_numbers

  has_one :primary_phone_number, class_name: "PhoneNumber", foreign_key: "person_id", conditions: {primary: true}
  has_many :locations
  has_one :latest_location, order: "updated_at DESC", class_name: 'Location'
  has_many :friends
  has_many :interests
  has_many :education_histories
  has_many :email_addresses
  has_one :primary_email_address, class_name: "EmailAddress", foreign_key: "person_id", conditions: {primary: true}
  has_one :primary_organization_membership, class_name: "OrganizationMembership", foreign_key: "person_id", conditions: {primary: true}
  has_one :primary_organization, through: :primary_organization_membership, source: :organization
  has_many :answer_sheets
  has_many :contact_assignments, class_name: "ContactAssignment", foreign_key: "assigned_to_id"
  has_many :assigned_tos, class_name: "ContactAssignment", foreign_key: "person_id"
  has_many :assigned_contacts, through: :contact_assignments, source: :assigned_to
  has_one :current_address, class_name: "Address", foreign_key: "fk_PersonID", conditions: {addressType: 'current'}
  has_many :rejoicables, inverse_of: :created_by

  has_many :organization_memberships, inverse_of: :person
  has_many :organizational_roles
  has_many :organizations, through: :organizational_roles, conditions: "role_id <> #{Role::CONTACT_ID}", uniq: true
  has_many :roles, through: :organizational_roles

  has_many :followup_comments, :class_name => "FollowupComment", :foreign_key => "commenter_id"
  has_many :comments_on_me, :class_name => "FollowupComment", :foreign_key => "contact_id"

  has_many :received_sms, class_name: "ReceivedSms", foreign_key: "person_id"
  has_many :sms_sessions, inverse_of: :person

  has_many :group_memberships

  has_one :person_photo

  scope :who_answered, lambda {|survey_id| includes(:answer_sheets).where(AnswerSheet.table_name + '.survey_id' => survey_id)}
  validates_presence_of :firstName
  validates_format_of :email, with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, allow_blank: true

  accepts_nested_attributes_for :email_addresses, :reject_if => lambda { |a| a[:email].blank? }, allow_destroy: true  
  accepts_nested_attributes_for :phone_numbers, :reject_if => lambda { |a| a[:number].blank? }, allow_destroy: true  
  accepts_nested_attributes_for :current_address, allow_destroy: true  

  before_save :stamp_changed
  before_create :stamp_created
  #after_update :update_date_attributes_updated

  scope :find_by_person_updated_by_daterange, lambda { |date_from, date_to| {
    :conditions => ["date_attributes_updated >= ? AND date_attributes_updated <= ? ", date_from, date_to]
  } }

  def update_date_attributes_updated
    self.date_attributes_updated = DateTime.now.to_s(:db)
    self.save
  end

  def self.search_by_name(name, organization_ids = nil, scope = nil)
    return scope.where('1 = 0') unless name.present?
    scope ||= Person
    query = name.strip.split(' ')
    first, last = query[0].to_s + '%', query[1].to_s + '%'
    if last == '%'
      conditions = ["preferredName like ? OR firstName like ? OR lastName like ?", first, first, first]
    else
      conditions = ["(preferredName like ? OR firstName like ?) AND lastName like ?", first, first, last]
    end
    scope = scope.where(conditions)
    scope = scope.where('organizational_roles.organization_id IN(?)', organization_ids).includes(:organizational_roles) if organization_ids
    scope
  end
  def to_s
    # [preferredName.blank? ? firstName : preferredName.try(:strip), lastName.try(:strip)].join(' ')
    [firstName.to_s, lastName.to_s.strip].join(' ')
  end

  def facebook_url
    if fb_uid.present?
      "http://www.facebook.com/profile.php?id=#{fb_uid}"
    end
  end

  def leader_in?(org)
    return false unless org
    OrganizationalRole.where(person_id: id, role_id: Role.leader_ids, :organization_id => org.id).present?
  end

  def orgs_with_children
    organizations.collect {|org|
      org.parent ? 
        org.parent.show_sub_orgs? ? 
        [org] + org.children
      : 
        [org] 
      : 
        org.show_sub_orgs? ?
        [org] + org.children
      :
        [org]
    }.flatten.uniq_by{ |o| o.id }

    #organizations.collect {|top_org| top_org.parent ? (top_org.show_sub_orgs? ? top_org.children + top_org.descendants : [])
    #  : ([top_org])
    #}.flatten
  end

  def phone_number
    @phone_number = primary_phone_number.try(:number)

    unless @phone_number
      if phone_numbers.present?
        @phone_number = phone_numbers.first.try(:number)
        phone_numbers.first.update_attribute(:primary, true)
      elsif current_address
        @phone_number = current_address.cellPhone.strip if current_address.cellPhone.present?
        @phone_number ||= current_address.homePhone.strip if current_address.homePhone.present?
        @phone_number ||= current_address.workPhone.strip if current_address.workPhone.present?
        begin
          new_record? ? phone_numbers.new(number: @phone_number, primary: true) : phone_numbers.create(number: @phone_number, primary: true) if @phone_number.present?
        rescue ActiveRecord::RecordNotUnique
          reload
          return self.phone_number
        end
      end
    end
    @phone_number.to_s
  end

  def pretty_phone_number
    primary_phone_number.try(:pretty_number)
  end

  def phone_number=(val)
    if val.is_a?(Hash)
      self.phone_number = val[:number]
    else
      if val.to_s.strip.blank?
        primary_phone_number.try(:destroy)
      else
        unless phone_numbers.find_by_number(PhoneNumber.strip_us_country_code(val))
          phone_number = primary_phone_number || phone_numbers.new
          phone_number.number = val
          phone_number.save
        end
      end
    end
    val
  end

  def name 
    [firstName, lastName].collect(&:to_s).join(' ') 
  end

  # def firstName
  #   preferredName.blank? ? self[:firstName].try(:strip) : preferredName.try(:strip)
  # end

  def self.find_from_facebook(data, authentication)
    EmailAddress.find_by_email(data.email).try(:person) if data.email.present?
  end

  def self.create_from_facebook(data, authentication, response = nil)
    if response.nil?
      response = MiniFB.get(authentication['token'], authentication['uid'])
    else
      response = response
    end
    new_person = Person.create(firstName: data['first_name'].try(:strip), lastName: data['last_name'].try(:strip))
    new_person.update_from_facebook(data, authentication, response)
    new_person
  end

  def update_from_facebook(data, authentication, response = nil)
    begin
      response = MiniFB.get(authentication['token'], authentication['uid']) if response.nil?
      begin
        self.birth_date = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birth_date.blank? && data['birthday'].present?
      rescue ArgumentError; end
      self.gender = response.gender unless (response.gender.nil? && !gender.blank?)
      # save!
      unless email_addresses.detect {|e| e.email == data['email']}
        begin
          email_addresses.find_or_create_by_email(data['email'].try(:strip)) if data['email'].try(:strip).present?
        rescue ActiveRecord::RecordNotUnique
          return self
        end
      end
      async_get_or_update_friends_and_interests(authentication)
      get_location(authentication, response)
      get_education_history(authentication, response)
    rescue MiniFB::FaceBookError => e
      Airbrake.notify(
        :error_class   => "MiniFB::FaceBookError",
        :error_message => "MiniFB::FaceBookError: #{e.message}",
        :parameters    => {data: data, authentication: authentication, response: response}
      )
    end
    self.fb_uid = authentication['uid']
    save(validate: false)
    self
  end

  def gender=(gender)
    if ['male','female'].include?(gender.to_s.downcase)
      self[:gender] = gender.downcase == 'male' ? '1' : '0'
    else
      self[:gender] = gender
    end
  end

  def gender
    if ['1','0'].include?(self[:gender])
      self[:gender] == '1' ? 'male' : 'female'
    else
      self[:gender]
    end
  end

  def email
    @email = primary_email_address.try(:email)
    unless @email
      if email_addresses.present?
        @email = email_addresses.first.try(:email)
        email_addresses.first.update_attribute(:primary, true) unless new_record?
      else
        @email ||= current_address.try(:email)
        @email ||= user.try(:username) || user.try(:email)
        begin
          new_record? ? email_addresses.new(:email => @email, :primary => true) : email_addresses.create(:email => @email, :primary => true) if @email
        rescue ActiveRecord::RecordNotUnique
          reload
        end
      end
    end
    @email.to_s
  end

  def email=(val)
    return if val.blank?
    existing = email_addresses.where(email: val).first
    if existing
      unless existing.primary?
        email_addresses.where(["email <> ?", val]).update_all(primary: false)
        existing.update_attribute(:primary, true)
      end
    else
      email = primary_email_address || email_addresses.new
      email.email = val
      email.save
    end
  end

  def email_address=(hash)
    self.email = hash['email']
  end

  def get_friends(authentication, response = nil)
    if friends.count == 0 
      if response.nil?
        @friends = MiniFB.get(authentication['token'], authentication['uid'],type: "friends")
      else @friends = response
      end
      @friends["data"].each do |friend|
        the_friend = friends.create(uid: friend['id'], name: friend['name'], person_id: personID.to_i, provider: "facebook")
        the_friend.follow!(self) unless the_friend.following?(self)
      end
    end
    @friends["data"].length  #return how many friend you got from facebook for testing
  end

  def update_friends(authentication, response = nil)
    if response.nil?
      @friends = MiniFB.get(authentication['token'], authentication['uid'],type: "friends")
    else @friends = response
    end
    @friends = @friends["data"]
    @removal = []
    @create = []
    @match = []
    @dbf = friends.reload

    @friends.each do |friend|
      @dbf.each do |dbf|
        if dbf['uid'] == friend.id
          @matching_friend = dbf if dbf['uid'] == friend.id
          break
        end
        @matching_friend = nil
      end
      if @matching_friend
        the_friend = friends.find_by_uid(@matching_friend.uid)
        the_friend.update_attributes(name: friend['name']) unless @matching_friend.name.eql?(friend['name'])
        @match.push(@matching_friend.uid)
      elsif friends.find_by_uid(friend.id).nil? #uid's did not match && the DB is empty
        the_friend = friends.create!(uid: friend['id'], name: friend['name'], person_id: personID.to_i, provider: "facebook")
        @create.push(friend['id'])
      end
      the_friend.follow!(self) unless the_friend.following?(self)
    end
    @dbf = friends.reload

    @dbf.each do |dbf|
      if !( @match.include?(dbf.uid) || @create.include?(dbf.uid) )
        friend_to_delete = friends.select('id').where("uid = ?", dbf.uid).first
        id_to_destroy = friend_to_delete['id'].to_i
        Friend.destroy(id_to_destroy)
        @removal.push(dbf.uid)
      end
    end
    @removal.length + @create.length  #create way to test how many changes were made
  end

  def get_interests(authentication, response = nil)
    if response.nil?
      @interests = MiniFB.get(authentication['token'], authentication['uid'],type: "interests")
    else @interests = response
    end
    @interests["data"].each do |interest|
      interests.find_or_initialize_by_interest_id_and_person_id_and_provider(interest['id'], personID.to_i, "facebook") do |i|
        i.provider = "facebook"
        i.category = interest['category']
        i.name = interest['name']
        i.interest_created_time = interest['created_time']
      end
      save
    end
    interests.count
  end

  def get_location(authentication, response = nil)
    if response.nil?
      @location = MiniFB.get(authentication['token'], authentication['uid']).location
    else @location = response.location
    end
    Location.find_or_create_by_location_id_and_name_and_person_id_and_provider(@location['id'], @location['name'], personID.to_i,"facebook") unless @location.nil?
  end

  def get_education_history(authentication, response = nil)
    if response.nil?
      @education = MiniFB.get(authentication['token'], authentication['uid']).education
    else @education = response.try(:education)
    end
    unless @education.nil?
      @education.each do |education|
        education_histories.find_or_initialize_by_school_id_and_person_id_and_provider(education.school.try(:id), personID.to_i, "facebook") do |e|
          e.year_id = education.year.try(:id) ? education.year.id : e.year_id
          e.year_name = education.year.try(:name) ? education.year.name : e.year_name
          e.school_type = education.try(:type) ? education.type : e.school_type
          e.school_name = education.school.try(:name) ? education.school.name : e.school_name
          unless education.try(:concentration).nil?
            0.upto(education.concentration.length-1) do |c|
              e["concentration_id#{c+1}"] = education.concentration[c].try(:id) ? education.concentration[c].id : e["concentration_id#{c+1}"]
              e["concentration_name#{c+1}"] = education.concentration[c].try(:name) ? education.concentration[c].name : e["concentration_name#{c+1}"]
            end
          end
          unless education.try(:degree).nil?
            e.degree_id = education.degree.try(:id) ? education.degree.id : e.degree_id
            e.degree_name = education.degree.try(:name) ? education.degree.name : e.degree_name
          end
          save(validate: false)
        end 
      end
    end
  end  

  def contact_friends(org)
    Person.where(fb_uid: friends.select(:uid).collect(&:uid)).joins(:organizational_roles).where('organizational_roles.role_id' => Role::CONTACT_ID, 'organizational_roles.organization_id' => org.id)
  end

  def remove_assigned_contacts(organization)
    assigned_contact_ids = contact_assignments.collect{ |r| r.person_id }
    ContactAssignment.where(person_id: assigned_contact_ids, organization_id: organization.id).destroy_all if assigned_contact_ids.count > 0
  end

  def smart_merge(other)
    if user && other.user
      user.merge(other.user)
      return self
    elsif other.user
      other.merge(self)
      return other
    else
      merge(other)
      return self
    end

  end

  def merge(other)
    return self if other.nil? || other == self
    # Phone Numbers
    phone_numbers.each do |pn|
      opn = other.phone_numbers.detect {|oa| oa.number == pn.number && oa.extension == pn.extension}
      pn.merge(opn) if opn
    end
    other.phone_numbers.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}

    # Locations
    other.locations.each do |location|
      if location_ids.include?(location.id)
        location.destroy
      else
        location.update_column(:person_id, id)
      end
    end

    other.friends.each do |friend|
      if friend_ids.include?(friend.id)
        friend.destroy
      else
        begin
          friend.update_column(:person_id, id) 
        rescue; end
      end
    end

    # Interests
    other.interests.each do |i|
      if interest_ids.include?(i.id)
        i.destroy
      else
        i.update_column(:person_id, id)
      end
    end

    # Edudation Histories
    other.education_histories.each do |eh|
      if education_history_ids.include?(eh.id)
        eh.destroy
      else
        eh.update_column(:person_id, id)
      end
    end

    # Followup Comments
    other.followup_comments.each do |fc|
      fc.update_column(:commenter_id, id)
    end

    # Comments on me
    other.comments_on_me.each do |fc|
      fc.update_column(:contact_id, id)
    end

    # Email Addresses
    email_addresses.each do |pn|
      opn = other.email_addresses.detect {|oa| oa.email == pn.email}
      pn.merge(opn) if opn
    end
    emails = email_addresses.collect(&:email)
    other.email_addresses.each do |pn| 
      if emails.include?(pn.email)
        pn.destroy
      else
        begin
          pn.update_attribute(:person_id, id) unless pn.frozen?
        rescue ActiveRecord::RecordNotUnique
          pn.destroy
        end
      end
    end

    # Organization Memberships
    organization_memberships.each do |pn|
      opn = other.organization_memberships.detect {|oa| oa.organization_id == pn.organization_id}
      pn.merge(opn) if opn
    end
    other.organization_memberships.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}

    # Organizational Roles
    organizational_roles.each do |pn|
      opn = other.organizational_roles.detect {|oa| oa.organization_id == pn.organization_id}
      pn.merge(opn) if opn
    end
    other.organizational_roles.each do |role| 
      begin
        role.update_attribute(:person_id, id) unless role.frozen?
      rescue ActiveRecord::RecordNotUnique
        role.destroy
      end
    end

    # Answer Sheets
    other.answer_sheets.collect {|as| as.update_column(:person_id, id)}

    # Contact Assignments
    other.contact_assignments.collect {|as| as.update_column(:assigned_to_id, id)}

    # SMS stuff
    other.received_sms.collect {|as| as.update_column(:person_id, id)}
    other.sms_sessions.collect {|as| as.update_column(:person_id, id)}

    # Group Memberships
    other.group_memberships.collect {|gm| gm.update_column(:person_id, id)}

    super
  end

  def to_hash_mini
    hash = {}
    hash['id'] = self.personID
    hash['name'] = self.to_s.gsub(/\n/," ")
    hash
  end
  
  def to_hash_micro_leader(organization)
   hash = to_hash_mini
   hash['picture'] = picture unless fb_uid.nil?
   hash['num_contacts'] = contact_assignments.for_org(organization).count 
   hash['fb_id'] = fb_uid.to_s unless fb_uid.nil?
   hash 
  end

  def to_hash_mini_leader(org_id)
    hash = to_hash_micro_leader(Organization.find(org_id))
    hash['organizational_roles'] = []
    organizational_roles.includes(:role, :organization).where("role_id <> #{Role::CONTACT_ID}").uniq {|r| r.organization_id}.collect do |r| 
      if om = organization_memberships.where(organization_id: r.organization_id).first
        hash['organizational_roles'] << {org_id: r.organization_id, role: r.role.i18n, name: r.organization.name, primary: om.primary? ? 'true' : 'false'}
        if r.organization.show_sub_orgs?
          r.organization.children.each do |o|
            hash['organizational_roles'] << {org_id: o.id, role: r.role.i18n, name: o.name, primary: 'false'}
          end
        end
      end
    end.compact
    hash
  end

  def to_hash_assign(organization = nil)
    hash = self.to_hash_mini
    assign_hash = nil
    unless organization.nil?
      assigned_to_person = ContactAssignment.where('assigned_to_id = ? AND organization_id = ?', id, organization.id)
      assigned_to_person = assigned_to_person.empty? ? [] : assigned_to_person.collect{ |a| a.person.try(:to_hash_mini) }
      person_assigned_to = ContactAssignment.where('person_id = ? AND organization_id = ?', id, organization.id)
      person_assigned_to = person_assigned_to.empty? ? [] : person_assigned_to.collect {|c| Person.find(c.assigned_to_id).try(:to_hash_mini)}
      assign_hash = {assigned_to_person: assigned_to_person, person_assigned_to: person_assigned_to}
    end
    hash['assignment'] = assign_hash unless assign_hash.nil?
    hash
  end

  def to_hash_basic(organization = nil)
    hash = self.to_hash_assign(organization)
    hash['gender'] = gender
    hash['fb_id'] = fb_uid.to_s unless fb_uid.nil?
    hash['picture'] = picture unless fb_uid.nil? and person_photo.nil?
    status = organizational_roles.where(organization_id: organization.id).where('followup_status IS NOT NULL') unless organization.nil?
    hash['status'] = status.first.followup_status unless (status.nil? || status.empty?)
    hash['request_org_id'] = organization.id unless organization.nil?
    hash['first_contact_date'] = answer_sheets.first.created_at.utc.to_s unless answer_sheets.empty?
    hash['date_surveyed'] = answer_sheets.last.created_at.utc.to_s unless answer_sheets.empty?
    hash['organizational_roles'] = []
    organizational_roles.includes(:role, :organization).where("role_id <> #{Role::CONTACT_ID}").uniq {|r| r.organization_id}.collect do |r| 
      if om = organization_memberships.where(organization_id: r.organization_id).first
        hash['organizational_roles'] << {org_id: r.organization_id, role: r.role.i18n, name: r.organization.name, primary: om.primary? ? 'true' : 'false'}
        if r.organization.show_sub_orgs?
          r.organization.children.each do |o|
            hash['organizational_roles'] << {org_id: o.id, role: r.role.i18n, name: o.name, primary: 'false'}
          end
        end
      end
    end.compact
    hash
  end

  def to_hash(organization = nil)
    hash = self.to_hash_basic(organization)
    hash['first_name'] = firstName.to_s.gsub(/\n/," ")
    hash['last_name'] = lastName.to_s.gsub(/\n/," ")
    hash['phone_number'] = primary_phone_number.number if primary_phone_number
    hash['email_address'] = primary_email_address.to_s if primary_email_address
    hash['birthday'] = birth_date.to_s
    hash['interests'] = Interest.get_interests_hash(id)
    hash['education'] = EducationHistory.get_education_history_hash(id)
    hash['location'] = latest_location.to_hash if latest_location
    hash['locale'] = user.try(:locale) ? user.locale : ""
    hash['organization_membership'] = organizations.collect(&:self_and_children).flatten.collect {|org| {org_id: org.id, primary: (primary_organization == org).to_s, name: org.name}}
    hash
  end

  def async_get_or_update_friends_and_interests(authentication)
    Resque.enqueue(Jobs::UpdateFB, self.id, authentication,'friends')
    Resque.enqueue(Jobs::UpdateFB, self.id, authentication,'interests')
  end

  def picture
    if person_photo
      Rails.env.development? ? "http://local.missionhub.com/#{person_photo.image.url}" : "http://www.missionhub.com/#{person_photo.image.url}"
    else
      "http://graph.facebook.com/#{fb_uid}/picture"
    end
  end

  def create_user!
    reload
    if email.present? && primary_email_address.valid?
      if user =  User.find_by_username(email)
        if user.person
          user.person.merge(self)
          return user.person
        else
          self.user = user
        end
      else
        self.user = User.create!(:username => email, :email => email, :password => SecureRandom.hex(10))
      end
      self.save(validate: false)
      return self
    else
      # Delete invalid emails
      self.email_addresses.each {|email| email.destroy unless email.valid?}
      return nil
    end
  end

  def updated_at() dateChanged end
  # def updated_by() changedBy end
  def created_at() dateCreated end
  def created_by() createdBy end

  def stamp_changed
    self.dateChanged = Time.now
    self.changedBy = ApplicationController.application_name
  end
  def stamp_created
    self.dateCreated = Time.now
    self.createdBy = ApplicationController.application_name
  end

  def self.new_from_params(person_params = nil)
    person_params = person_params.with_indifferent_access || {}
    person_params[:email_address] ||= {}
    person_params[:phone_number] ||= {}
    # try to find this person based on their email address
    email_address = person_params[:email_address][:email]
    if email_address.present?
      person = EmailAddress.find_by_email(email_address).try(:person) ||
        Address.find_by_email(email_address).try(:person) ||
        User.find_by_username(email_address).try(:person) 
    end
    person ||= Person.new(person_params.except(:email_address, :phone_number))
    email = (person.email_addresses.find_by_email(email_address) || person.email_addresses.new(email: email_address)) if email_address.present? 
    if person_params[:phone_number][:number].present?
      phone = (person.phone_numbers.find_by_number(person_params[:phone_number][:number].gsub(/[^\d]/, '')) || person.phone_numbers.new(person_params.delete(:phone_number).except(:_destroy).merge(location: 'mobile'))) 
    end
    unless person.new_record?
      email.save if email
      phone.save if phone
    end
    [person, email, phone]
  end

  def do_not_contact(organizational_role_id)
    organizational_role = OrganizationalRole.find(organizational_role_id)
    organizational_role.followup_status = 'do_not_contact'
    ContactAssignment.where(person_id: self.id, organization_id: organizational_role.organization_id).destroy_all
    organizational_role.save
  end

  def friends_and_leaders(organization)
    Friend.followers(self) & organization.leaders.collect(&:fb_uid).collect(&:to_s)
  end

  def assigned_organizational_roles(organizations)
    roles.where('organizational_roles.organization_id' => organizations)
  end

  def self.vcard(ids)
    ids = Array.wrap(ids)
    book = Vpim::Book.new
    Person.includes(:current_address, :primary_phone_number, :primary_email_address).find(ids).each do |person|
      book << person.vcard
    end
    book
  end

  def vcard

    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.prefix = ''
        name.given = firstName
        name.family = lastName
      end

      if current_address
        maker.add_addr do |addr|
          addr.preferred = true
          addr.location = 'home'
          addr.street =  "#{current_address.address1} #{current_address.address2}" if current_address.address1.present? || current_address.address2.present?
          addr.locality = current_address.city if current_address.city.present?
          addr.postalcode = current_address.zip if current_address.zip.present?
          addr.region = current_address.state if current_address.state.present?
          addr.country = current_address.country if current_address.country.present?
        end
      end

      maker.birthday = birth_date if birth_date
      maker.add_tel(phone_number) if phone_number != ''
      if email != ''
        maker.add_email(email) do |email|
          email.preferred = true
          email.location = 'home'
        end  
      end
    end

  end  
end
