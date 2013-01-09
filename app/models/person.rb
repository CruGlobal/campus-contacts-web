require 'vpim/vcard'
require 'vpim/book'

class Person < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { person_id: :id }

  has_one :sent_person
  has_many :person_transfers
  has_many :new_people
  has_one :transferred_by, class_name: "PersonTransfer", foreign_key: "transferred_by_id"
  belongs_to :user, class_name: 'User', foreign_key: 'user_id'
  has_many :phone_numbers, autosave: true
  has_one :primary_phone_number, class_name: "PhoneNumber", foreign_key: "person_id", conditions: {primary: true}
  has_many :locations
  has_one :latest_location, order: "updated_at DESC", class_name: 'Location'
  has_many :interests
  has_many :education_histories
  has_many :email_addresses, autosave: true
  has_one :primary_email_address, class_name: "EmailAddress", foreign_key: "person_id", conditions: {primary: true}
  has_one :primary_org_role, class_name: "OrganizationalRole", foreign_key: "person_id", conditions: {primary: true}
  has_one :primary_org, through: :primary_org_role, source: :organization
  has_many :answer_sheets
  has_many :contact_assignments, class_name: "ContactAssignment", foreign_key: "assigned_to_id", dependent: :destroy
  has_many :assigned_tos, class_name: "ContactAssignment", foreign_key: "person_id"
  has_many :assigned_contacts, through: :contact_assignments, source: :assigned_to
  has_one :current_address, class_name: "Address", foreign_key: "person_id", conditions: {address_type: 'current'}, autosave: true
  has_many :addresses, class_name: 'Address', foreign_key: :person_id, dependent: :destroy
  has_many :rejoicables, inverse_of: :person

  has_many :organization_memberships, inverse_of: :person
  has_many :organizational_roles, conditions: {archive_date: nil}
  has_one :contact_role, class_name: 'OrganizationalRole'
  has_many :roles, through: :organizational_roles
  has_many :organizational_roles_including_archived, class_name: "OrganizationalRole", foreign_key: "person_id"
  has_many :roles_including_archived, through: :organizational_roles_including_archived, source: :role
  has_many :organizations, through: :organizational_roles, conditions: ["role_id IN(?) AND status = 'active'", Role.involved_ids], uniq: true

  has_many :followup_comments, :class_name => "FollowupComment", :foreign_key => "commenter_id"
  has_many :comments_on_me, :class_name => "FollowupComment", :foreign_key => "contact_id"

  has_many :received_sms, class_name: "ReceivedSms", foreign_key: "person_id"
  has_many :sms_sessions, inverse_of: :person

  has_many :group_memberships

  has_one :person_photo

  scope :who_answered, lambda {|survey_id| includes(:answer_sheets).where(AnswerSheet.table_name + '.survey_id' => survey_id)}
  validates_presence_of :first_name
  #validates_format_of :email, with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, allow_blank: true

  validate do |value|
    birth_date = value.birth_date_before_type_cast
    return unless birth_date.present?
    if birth_date =~ /^([1-9]|0[1-9]|1[012])\/([1-9]|0[1-9]|[12][1-9]|3[01])\/(19|2\d)\d\d$/
      begin
        date_str = birth_date.split('/')
        self[:birth_date] = Date.parse("#{date_str[2]}-#{date_str[0]}-#{date_str[1]}")
      rescue
        errors.add(:birth_date, "invalid")
      end
    elsif birth_date.is_a?(Date)
      self[:birth_date] = birth_date
    else
      errors.add(:birth_date, "invalid")
    end
  end

  accepts_nested_attributes_for :email_addresses, :reject_if => lambda { |a| a[:email].blank? }, allow_destroy: true
  accepts_nested_attributes_for :phone_numbers, :reject_if => lambda { |a| a[:number].blank? }, allow_destroy: true
  accepts_nested_attributes_for :current_address, allow_destroy: true

  scope :find_by_person_updated_by_daterange, lambda { |date_from, date_to| {
    :conditions => ["date_attributes_updated >= ? AND date_attributes_updated <= ? ", date_from, date_to]
  }}

  scope :find_by_last_login_date_before_date_given, lambda { |after_date| {
    :select => "people.*",
    :joins => "JOIN users AS ssm ON ssm.id = people.user_id",
    :conditions => ["ssm.current_sign_in_at <= ? OR (ssm.current_sign_in_at IS NULL AND ssm.created_at <= ?)", after_date, after_date]
  }}

  scope :find_by_date_created_before_date_given, lambda { |before_date| {
    :select => "people.*",
    :joins => "LEFT JOIN organizational_roles AS ors ON people.id = ors.person_id",
    :conditions => ["ors.role_id = ? AND ors.created_at <= ? AND ors.archive_date IS NULL", Role::CONTACT_ID, before_date]
  }}

  scope :order_by_highest_default_role, lambda { |order, tables_already_joined = false| {
    :select => "people.*",
    :joins => "#{'JOIN organizational_roles ON people.id = organizational_roles.person_id JOIN roles ON organizational_roles.role_id = roles.id' unless tables_already_joined}",
    :conditions => "roles.i18n IN #{Role.default_roles_for_field_string(order.include?("asc") ? Role::DEFAULT_ROLES : Role::DEFAULT_ROLES.reverse)}",
    :order => "FIELD#{Role.i18n_field_plus_default_roles_for_field_string(order.include?("asc") ? Role::DEFAULT_ROLES : Role::DEFAULT_ROLES.reverse)}"
  } }

  scope :order_by_followup_status, lambda { |order| {
    :order => "ISNULL(organizational_roles.followup_status) #{order.include?("asc") ? 'ASC' : 'DESC'}, organizational_roles.#{order}"
  } }

  scope :order_by_primary_phone_number, lambda { |order| {
    :select => "people.*",
    :joins => "LEFT JOIN `phone_numbers` ON `phone_numbers`.`person_id` = `people`.`id` AND `phone_numbers`.`primary` = 1",
    :order => "phone_numbers.number #{order.include?("asc") ? 'ASC' : 'DESC'}"
  } }

  scope :order_alphabetically_by_non_default_role, lambda { |order, tables_already_joined = false| {
    :select => "people.*",
    :joins => "#{'JOIN organizational_roles ON people.id = organizational_roles.person_id JOIN roles ON organizational_roles.role_id = roles.id' unless tables_already_joined}",
    :conditions => "roles.name NOT IN #{Role.default_roles_for_field_string(order.include?("asc") ? Role::DEFAULT_ROLES : Role::DEFAULT_ROLES.reverse)}",
    :order => "roles.name #{order.include?("asc") ? 'DESC' : 'ASC'}"
  } }

  scope :find_friends_with_fb_uid, lambda { |person| { conditions: {fb_uid: Friend.followers(person)} } }

  scope :search_by_name_or_email, lambda { |keyword, org_id| {
    :select => "people.*",
    :conditions => ["(org_roles.organization_id = #{org_id} AND (concat(first_name,' ',last_name) LIKE ? OR concat(last_name, ' ',first_name) LIKE ? OR emails.email LIKE ?))", "%#{keyword}%", "%#{keyword}%", "%#{keyword}%"],
    :joins => "LEFT JOIN email_addresses AS emails ON emails.person_id = people.id LEFT JOIN organizational_roles AS org_roles ON people.id = org_roles.person_id"
  } }

  scope :get_and_order_by_latest_answer_sheet_answered, lambda { |order, org_id| {
    #"SELECT * FROM (SELECT * FROM missionhub_dev.people mp INNER JOIN missionhub_dev.organizational_roles ro ON mp.id = ro.person_id WHERE ro.organization_id = #{@organization.id} AND (ro.role_id = 3 AND ro.followup_status <> 'do_not_contact')) mp LEFT JOIN (SELECT ass.updated_at, ass.person_id FROM missionhub_dev.answer_sheets ass INNER JOIN missionhub_dev.surveys ms ON ms.id = ass.survey_id WHERE ms.organization_id = #{@organization.id}) ass ON ass.person_id = mp.id GROUP BY mp.id ORDER BY #{params[:q][:s].gsub('answer_sheets', 'ass')}"
    :joins => "LEFT JOIN (SELECT ass.updated_at, ass.person_id FROM answer_sheets ass INNER JOIN surveys ms ON ms.id = ass.survey_id WHERE ms.organization_id = #{org_id} ORDER BY ass.updated_at DESC) ass ON ass.person_id = people.id",
    :group => "people.id",
    :order => "ISNULL(ass.updated_at), ass.updated_at #{order.include?("asc") ? 'DESC' : 'ASC'}"
  }}

  def contact_role_for_org(org)
    organizational_roles.where("organizational_roles.organization_id = ? AND organizational_roles.role_id = ?", org.id, Role::CONTACT_ID).first
  end

  def completed_answer_sheets(organization)
    answer_sheets.where("survey_id IN (?)", Survey.where("organization_id = ? OR id = ?", organization.id, APP_CONFIG['predefined_survey']).collect(&:id)).order('updated_at DESC')
  end

  def latest_answer_sheet(organization)
    completed_answer_sheets(organization).first
  end

  def answered_surveys_hash(organization)
    surveys = Array.new
    completed_answer_sheets(organization).each do |answer_sheet|
      survey = Hash.new
      survey['keyword'] = answer_sheet.survey.title
      survey['date'] = answer_sheet.updated_at
      surveys << survey
    end
    return surveys
  end

  scope :get_archived, lambda { |org_id| {
    :conditions => "organizational_roles.archive_date IS NOT NULL",
    :group => "people.id",
    :having => "COUNT(*) = (SELECT COUNT(*) FROM people AS mpp JOIN organizational_roles orss ON mpp.id = orss.person_id WHERE mpp.id = people.id AND orss.organization_id = #{org_id})"
  } }

  scope :get_from_group, lambda { |group_id| {
    :select => "people.*",
    :joins => "LEFT JOIN #{GroupMembership.table_name} AS gm ON gm.person_id = people.id",
    :conditions => ["gm.group_id = ?", group_id]
  } }

  def self.archived(org_id)
    self.get_archived(org_id).collect()
  end

  def self.people_for_labels(org)
    Person.where('organizational_roles.organization_id' => org.id).includes(:organizational_roles)
  end

  scope :get_archived_included, lambda { {
    :group => "people.id"
  } }

  def self.archived_included
    self.get_archived_included.collect()
  end

  scope :get_archived_not_included, lambda { {
    :conditions => "organizational_roles.archive_date IS NULL",
    :group => "people.id"
  } }

  def self.archived_not_included
    self.get_archived_not_included.collect()
  end

  def select_name
    "#{first_name} #{last_name} #{'-' if last_name.present? || first_name.present?} #{pretty_phone_number}"
  end

  def select_name_email
    "#{first_name} #{last_name} #{'-' if last_name.present? || first_name.present?} #{email}"
  end

  def set_as_sent
    SentPerson.find_or_create_by_person_id(id)
  end

  def self.deleted
    self.get_deleted.collect()
  end

  def unachive_contact_role(org)
    OrganizationalRole.where(organization_id: org.id, role_id: Role::CONTACT_ID, person_id: id).first.unarchive
  end

  def archive_contact_role(org)
    begin
      OrganizationalRole.where(organization_id: org.id, role_id: Role::CONTACT_ID, person_id: id).first.archive
    rescue

    end
  end

  def archive_leader_role(org)
    begin
      OrganizationalRole.where(organization_id: org.id, role_id: Role::LEADER_ID, person_id: id).first.archive
    rescue

    end
  end

  def is_archived?(org)
    return true if organizational_roles.where(organization_id: org.id).blank?
    false
  end

  def assigned_tos_by_org(org)
    assigned_tos.where(organization_id: org.id)
  end

  def has_similar_person_by_name_and_email?(email)
    Person.joins(:primary_email_address).where(first_name: first_name, last_name: last_name, 'email_addresses.email' => email).where("people.id != ?", id).first
  end

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
      conditions = ["first_name like ? OR last_name like ?", first, first]
    else
      conditions = ["first_name like ? AND last_name like ?", first, last]
    end
    scope = scope.where(conditions)
    scope = scope.where('organizational_roles.organization_id IN(?)', organization_ids).includes(:organizational_roles) if organization_ids
    scope
  end

  def self.search_by_name_with_email_present(name, organization_ids = nil, scope = nil)
    search_by_name(name, organization_ids, scope).
      includes(:primary_email_address).
      where('email_addresses.email IS NOT NULL')
  end

  def to_s
    [first_name.to_s, last_name.to_s.strip].join(' ')
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
  def organization_objects
    @organization_objects ||= Hash[Organization.order('name').find_all_by_id(org_ids.keys).collect {|o| [o.id, o]}]
  end

  def org_ids
    unless @org_ids
      unless Rails.cache.exist?(['org_ids_cache', self])
        organization_tree # make sure the tree is built
      end
      # convert org ids to integers (there has to be a better way, but i couldn't think of it)
      @org_ids = {}
      org_ids_cache.collect {|org_id, values| @org_ids[org_id.to_i] = values} if org_ids_cache.present?
    end
    @org_ids
  end

  #def clear_org_cache
    #update_column(:organization_tree_cache, nil)
    #update_column(:org_ids_cache, nil)
  #end

  def organization_tree
    Rails.cache.fetch(['organization_tree', self]) do
      tree = org_tree_node
      Rails.cache.write(['org_ids_cache', self], @org_ids)
      tree
    end
  end

  def org_ids_cache
    unless Rails.cache.exist?(['org_ids_cache', self])
      organization_tree # make sure the tree is built
    end
    Rails.cache.fetch(['org_ids_cache', self])
  end

  def organization_from_id(org_id)
    begin
      organization_objects[org_id.to_i]
    #rescue
      #raise org_id.inspect
    end
  end

  def roles_by_org_id(org_id)
    unless @roles_by_org_id
      @roles_by_org_id = Hash[OrganizationalRole.connection.select_all("select organization_id, group_concat(role_id) as role_ids from organizational_roles where person_id = #{id} and archive_date is NULL group by organization_id").collect { |row| [row['organization_id'], row['role_ids'].split(',').map(&:to_i) ]}]
    end
    @roles_by_org_id[org_id]
  end

  def org_tree_node(o = nil, parent_roles = [])
    orgs = {}
    @org_ids ||= {}
    (o ? o.children : organizations).order('name').each do |org|
      # collect roles associated with each org
      @org_ids[org.id] ||= {}
      @org_ids[org.id]['roles'] = (Array.wrap(@org_ids[org.id]['roles']) + Array.wrap(roles_by_org_id(org.id)) + Array.wrap(parent_roles)).uniq
      orgs[org.id] = (org.show_sub_orgs? ? org_tree_node(org, @org_ids[org.id]['roles']) : {})
    end
    orgs
  end

  def admin_of_org_ids
    @admin_of_org_ids ||= org_ids.select {|org_id, values| Array.wrap(values['roles']).include?(Role.admin.id)}.keys
  end

  def leader_of_org_ids
    @leader_of_org_ids ||= org_ids.select {|org_id, values| (Array.wrap(values['roles']) & Role.leader_ids).present?}.keys
  end

  def admin_or_leader?
    (admin_of_org_ids + leader_of_org_ids).present?
  end


  def orgs_with_children
    organizations.collect {|org|
      if org.parent
        org.parent.show_sub_orgs? ? [org] + org.children : [org]
      else
        org.show_sub_orgs? ? [org] + org.children : [org]
      end
    }.flatten.uniq_by{ |o| o.id }
  end

  def all_organization_and_children
    orgs = Array.new
    organizations.each do |org|
      orgs << org
      child_org = collect_all_child_organizations(org)
      orgs += child_org
    end
    Organization.where(id: orgs.collect(&:id))
  end

  def collect_all_child_organizations(org)
    child_orgs = Array.new
    if org.children.present?
      org.children.each do |child_org|
        child_orgs << child_org
        other_child_org = collect_all_child_organizations(child_org)
        child_orgs += other_child_org
      end
    end
    child_orgs
  end

  def phone_number
    @phone_number = phone_numbers.detect(&:primary?).try(:number)

    unless @phone_number
      if phone_numbers.present?
        @phone_number = phone_numbers.first.try(:number)
        phone_numbers.first.update_attribute(:primary, true)
      end
    end
    @phone_number.to_s
  end

  def pretty_phone_number
    primary_phone_number.try(:pretty_number)
  end

  def phone_number=(val)
    p = nil
    if val.is_a?(Hash)
      p = self.phone_number = val[:number]
    else
      if val.to_s.strip.blank?
        primary_phone_number.try(:destroy)
      else
        if new_record? || (p = phone_numbers.find_by_number(PhoneNumber.strip_us_country_code(val))).blank?
          p = primary_phone_number || phone_numbers.new
          p.number = val
        end
        p.primary = true
      end
    end
    p
  end


  delegate :address1, :address1=, :city, :city=, :state, :state=, :zip, :zip=, :country, :country=, :dorm, :dorm=, :room, :room=, to: :current_or_blank_address

  def current_or_blank_address
    self.current_address ||= build_current_address
  end

  def name
    [first_name, last_name].collect(&:to_s).join(' ')
  end

  def self.find_from_facebook(data)
    EmailAddress.find_by_email(data.email).try(:person) if data.email.present?
  end

  def self.create_from_facebook(data, authentication, response = nil)
    new_person = Person.create(first_name: data['first_name'].try(:strip), last_name: data['last_name'].try(:strip))
    begin
      if response.nil?
        response = MiniFB.get(authentication['token'], authentication['uid'])
      else
        response = response
      end
      new_person.update_from_facebook(data, authentication, response)
    rescue MiniFB::FaceBookError => e
      Airbrake.notify(
        :error_class   => "MiniFB::FaceBookError",
        :error_message => "MiniFB::FaceBookError: #{e.message}",
        :parameters    => {data: data, authentication: authentication, response: response}
      )
    end
    new_person
  end

  def update_from_facebook(data, authentication, response = nil)
    begin
      response ||= MiniFB.get(authentication['token'], authentication['uid'])
      begin
        self.birth_date = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birth_date.blank? && data['birthday'].present?
      rescue ArgumentError; end
      self.gender = response.gender unless (response.gender.nil? && !gender.blank?)
      # save!
      unless email_addresses.detect {|e| e.email == data['email']}
        begin
          email_addresses.find_or_create_by_email(data['email'].strip) if data['email'].present?
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
    begin
      save(validate: false)
    rescue => e
      Airbrake.notify(
        :error_class   => e.class,
        :error_message => e.message,
        :parameters    => {data: data, authentication: authentication, response: response}
      )
    end
    self
  end

  def primary_organization=(org)
    if org.present? && user
      user.primary_organization_id = org.id
      user.save!
    end
    begin
      touch # touch the timestamp to reset caches
    rescue ActiveRecord::ReadOnlyRecord
    end
  end

  def primary_organization
    unless @primary_organization
      org = organizations.find_by_id(user.primary_organization_id) if user && user.primary_organization_id.present?
      unless org
        org = organizations.first

        # save this as the primary org
        self.primary_organization = org
      end
      @primary_organization = org
    end
    @primary_organization
  end

  def gender=(gender)
    if ['male','female'].include?(gender.to_s.downcase)
      self[:gender] = gender.downcase == 'male' ? '1' : '0'
    else
      self[:gender] = gender
    end
  end

  def gender
    if ['1','0'].include?(self[:gender].to_s)
      self[:gender].to_s == '1' ? 'Male' : 'Female'
    else
      self[:gender]
    end
  end

  def email
    @email = primary_email_address.try(:email)
    @email.to_s
  end

  def email=(val)
    return if val.blank?
    e = email_addresses.detect { |email| email.email == val }
    if e
      e.primary = true
    else
      e = email_addresses.new(email: val, primary: true)
    end
    e
  end

  def email_address=(hash)
    self.email = hash['email']
  end

  def get_friends(authentication, response = nil)
    if friends.length == 0
      response ||= MiniFB.get(authentication['token'], authentication['uid'],type: "friends")
      @friends = response['data']

      @friends.each do |friend|
        Friend.new(friend['id'], friend['name'], self)
      end
      @friends.length  #return how many friend you got from facebook for testing
    end
  end

  def update_friends(authentication, response = nil)
    response ||= MiniFB.get(authentication['token'], authentication['uid'],type: "friends")
    @fb_friends = response["data"]

    @fb_friends.each do |fb_friend|
      Friend.new(fb_friend['id'], fb_friend['name'], self)
    end

    (Friend.followers(self) - @fb_friends.collect {|f| f['id'] }).each do |uid|
      Friend.unfollow(self, uid)
    end
  end

  def get_interests(authentication, response = nil)
    if response.nil?
      @interests = MiniFB.get(authentication['token'], authentication['uid'],type: "interests")
    else @interests = response
    end
    @interests["data"].each do |interest|
      interests.find_or_initialize_by_interest_id_and_person_id_and_provider(interest['id'], id.to_i, "facebook") do |i|
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
    Location.find_or_create_by_location_id_and_name_and_person_id_and_provider(@location['id'], @location['name'], id.to_i,"facebook") unless @location.nil?
  end

  def get_education_history(authentication, response = nil)
    if response.nil?
      @education = MiniFB.get(authentication['token'], authentication['uid']).education
    else @education = response.try(:education)
    end
    unless @education.nil?
      @education.each do |education|
        education_histories.find_or_initialize_by_school_id_and_person_id_and_provider(education.school.try(:id), id.to_i, "facebook") do |e|
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
    org.people.find_friends_with_fb_uid(self)
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


  def friends
    Person.where(fb_uid: friend_uids)
  end

  def friend_uids
    Friend.followers(self)
  end

  def merge(other)
    return self if other.nil? || other == self
    reload
    ::Person.transaction do
      attributes.each do |k, v|
        next if k == ::Person.primary_key
        next if v == other.attributes[k]
        self[k] = case
                  when other.attributes[k].blank? then v
                  when v.blank? then other.attributes[k]
                  else
                    other_date = other.updated_at || other.created_at
                    this_date = updated_at || created_at
                    if other_date && this_date
                      other_date > this_date ? other.attributes[k] : v
                    else
                      v
                    end
                  end
      end

      # Addresses
      addresses.each do |address|
        other_address = other.addresses.detect {|oa| oa.address_type == address.address_type}
        address.merge(other_address) if other_address
      end
      other.addresses do |address|
        other_address = addresses.detect {|oa| oa.address_type == address.address_type}
        address.update_attribute(:person_id, id) unless address.frozen? || other_address
      end
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

      Friend.followers(other).each do |uid|
        friend = Friend.new(uid, nil, self)
        friend.unfollow(other)
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

      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
      begin
        save(validate: false)
      rescue ActiveRecord::ReadOnlyRecord

      end

      reload
      self

    end
  end

  def to_hash_mini
    hash = {}
    hash['id'] = self.id
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
    hash = to_hash_micro_leader(organization_from_id(org_id))
    hash['organizational_roles'] = organizational_roles_hash
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
    hash['organizational_roles'] = organizational_roles_hash
    hash
  end

  def organizational_roles_hash
    roles = {}
    @organizational_roles_hash ||= org_ids.collect { |org_id, values|
                                     values['roles'].select { |role_id|
                                       role_id != Role.contact.id
                                     }.collect { |role_id|
                                       roles[role_id] ||= Role.find_by_id(role_id)
                                     }.compact.collect { |role|
                                       {org_id: org_id, role: role.i18n, name: organization_from_id(org_id).try(:name), primary: primary_organization.id == org_id ? 'true' : 'false'}
                                     }
                                   }.flatten
  end

  def to_hash(organization = nil)
    hash = self.to_hash_basic(organization)
    hash['first_name'] = first_name.to_s.gsub(/\n/," ")
    hash['last_name'] = last_name.to_s.gsub(/\n/," ")
    hash['phone_number'] = primary_phone_number.number if primary_phone_number
    hash['email_address'] = primary_email_address.to_s if primary_email_address
    hash['birthday'] = birth_date.to_s
    hash['interests'] = Interest.get_interests_hash(id)
    hash['education'] = EducationHistory.get_education_history_hash(id)
    hash['location'] = latest_location.to_hash if latest_location
    hash['locale'] = user.try(:locale) ? user.locale : ""
    hash['organization_membership'] = organization_objects.collect {|org_id, org| {org_id: org_id, primary: (primary_organization.id == org.id).to_s, name: org.name}}
    hash
  end

  def async_get_or_update_friends_and_interests(authentication)
    Resque.enqueue(Jobs::UpdateFB, self.id, authentication,'friends')
    Resque.enqueue(Jobs::UpdateFB, self.id, authentication,'interests')
  end

  def picture
    if person_photo
      Rails.env.development? ? "http://local.missionhub.com/#{person_photo.image.url}" : "http://www.missionhub.com/#{person_photo.image.url}"
    elsif fb_uid.present?
      "http://graph.facebook.com/#{fb_uid}/picture"
    end
  end

  def create_user!
    reload
    if email.present? && has_a_valid_email? #!primary_email_address.nil? ? primary_email_address.valid? : false
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

  def created_by() createdBy end

  def self.new_from_params(person_params = nil)
    person_params = person_params.with_indifferent_access || {}
    person_params[:email_address] ||= {}
    person_params[:phone_number] ||= {}

    person = Person.new(person_params.except(:email_address, :phone_number))
    person.email_address = person_params[:email_address]
    person.phone_number = person_params[:phone_number]

    find_existing_person(person)
  end
  def self.find_existing_person_by_name_and_phone(opts = {})
    opts[:number] = PhoneNumber.strip_us_country_code(opts[:number])
    return unless opts.slice(:first_name, :last_name, :number).all? {|_, v| v.present?}

    Person.where(first_name: opts[:first_name], last_name: opts[:last_name], 'phone_numbers.number' => opts[:number]).
           includes(:phone_numbers).first
  end

  def self.find_existing_person_by_email(email)
    return unless email.present?
    (EmailAddress.find_by_email(email) ||
      User.find_by_username(email) ||
      User.find_by_email(email)).try(:person)
  end

  def self.find_existing_person_by_email_address(email_address)
    return unless email_address
    find_existing_person_by_email(email_address.email)
  end

  def self.find_existing_person(person)
    other_person = find_existing_person_by_email_address(person.email_addresses.first)

    if other_person
      person.phone_numbers.each do |phone_number|
        if phone_number.number.present?
          other_person.phone_numbers.create(phone_number.attributes.except('person_id','id'))
        end
      end
      phone = other_person.phone_numbers.first
      email = other_person.email_addresses.first
      other_person.attributes = person.attributes.except('id').select {|_, v| v.present?}
    else
      email = person.email_addresses.first
      phone = person.phone_numbers.first
    end

    #[other_person || person, email, phone]
    other_person || person
  end

  def do_not_contact(organizational_role_id)
    organizational_role = OrganizationalRole.find(organizational_role_id)
    organizational_role.followup_status = 'do_not_contact'
    ContactAssignment.where(person_id: self.id, organization_id: organizational_role.organization_id).destroy_all
    organizational_role.save
  end

  def friends_and_leaders(organization)
    Friend.followers(self) & organization.leaders.collect { |l| l.fb_uid.to_s }
  end

  def assigned_organizational_roles(organization_id)
    roles.where('organizational_roles.organization_id' => organization_id)
  end

  def assigned_organizational_roles_including_archived(organization_id)
    roles_including_archived.where('organizational_roles.organization_id' => organization_id)
  end

  def is_role_archived?(org_id, role_id)
    return false if organizational_roles_including_archived.where(organization_id: org_id, role_id: role_id).first.archive_date.blank?
    true
  end

  def is_sent?
    sent_person != nil
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
        name.given = first_name
        name.family = last_name
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

  def has_a_valid_email?
    return email.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
  end

end
