require 'name_uniqueness_validator'
require 'retryable'

class Organization < ActiveRecord::Base
  attr_accessor :person_id

  has_ancestry
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :parent_id }

  has_many :interactions
  has_many :labels, inverse_of: :organization
  has_many :organizational_labels, inverse_of: :organization

  belongs_to :importable, polymorphic: true
  has_many :messages
  has_many :group_labels
  has_many :activities, dependent: :destroy
  has_many :target_areas, through: :activities, class_name: 'TargetArea'
  has_many :people, through: :organizational_permissions, uniq: true
  has_many :not_archived_people, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.archive_date is NULL"], uniq: true
  has_many :contact_assignments
  has_many :keywords, class_name: 'SmsKeyword'
  has_many :surveys, dependent: :destroy
  has_many :survey_elements, through: :surveys
  has_many :questions, through: :surveys
  has_many :all_questions, through: :surveys, source: :all_questions
  has_many :answers, through: :all_questions, source: :answers
  has_many :followup_comments
  has_many :organizational_permissions, inverse_of: :organization
  has_many :movement_indicator_suggestions

  if Permission.table_exists? # added for travis testing
    has_many :leaders, through: :organizational_labels, source: :person, conditions: ["organizational_labels.label_id IN (?) AND organizational_labels.removed_date IS NULL", Label::LEADER_ID], order: "people.last_name, people.first_name", uniq: true

    def sent
      people_ids = Interaction.where(organization_id: id, interaction_type_id: InteractionType.graduating_on_mission.try(:id))
      contacts.where(id: people_ids.collect(&:receiver_id)).order('people.last_name, people.first_name').uniq
    end

    has_many :only_users, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.archive_date IS NULL", Permission::USER_ID], order: "people.last_name, people.first_name", uniq: true
    has_many :users, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id IN (?) AND organizational_permissions.archive_date IS NULL", [Permission::USER_ID, Permission::ADMIN_ID]], order: "people.last_name, people.first_name", uniq: true
    has_many :admins, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.archive_date IS NULL", Permission::ADMIN_ID], order: "people.last_name, people.first_name", uniq: true
    has_many :all_people, through: :organizational_permissions, source: :person, conditions: ["(organizational_permissions.followup_status <> 'do_not_contact' OR organizational_permissions.followup_status IS NULL) AND organizational_permissions.archive_date IS NULL"], uniq: true
    has_many :all_people_with_archived, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.followup_status <> 'do_not_contact' OR organizational_permissions.followup_status IS NULL"], uniq: true
    has_many :contacts, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.archive_date IS NULL AND organizational_permissions.followup_status <> 'do_not_contact'", Permission::NO_PERMISSIONS_ID]
    has_many :contacts_with_archived, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.followup_status <> 'do_not_contact'", Permission::NO_PERMISSIONS_ID]
    has_many :all_archived_people, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.archive_date IS NOT NULL AND organizational_permissions.followup_status <> 'do_not_contact'"]
    has_many :dnc_contacts, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.archive_date IS NULL AND organizational_permissions.followup_status = 'do_not_contact'"]
    has_many :completed_contacts, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.archive_date IS NULL AND organizational_permissions.followup_status = ?", Permission::NO_PERMISSIONS_ID, 'completed']
    has_many :completed_contacts_with_archived, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.followup_status = ?", Permission::NO_PERMISSIONS_ID, 'completed']
    has_many :no_activity_contacts, through: :organizational_permissions, source: :person, conditions: ["organizational_permissions.permission_id = ? AND organizational_permissions.archive_date IS NULL AND organizational_permissions.followup_status = ?", Permission::NO_PERMISSIONS_ID, 'uncontacted']
  end

  has_many :rejoicables
  has_many :groups
  has_one :api_client, class_name: 'Rack::OAuth2::Server::Client', inverse_of: :organization
  belongs_to :conference, class_name: 'Ccc::Crs2Conference', foreign_key: 'conference_id'

  Rejoicable::OPTIONS.each do |option|
    has_many :"#{option}_contacts", :through => :rejoicables, source: :person, conditions: {'rejoicables.what' => option}, uniq: true
  end

  default_value_for :show_sub_orgs, true

  validates_presence_of :name, :terminology#, :person_id
  validates :name, :name_uniqueness => true

  @queue = :general
  after_create :create_admin_user, :notify_admin_of_request, :touch_people
  after_destroy :touch_people
  after_update :touch_people_if_show_sub_orgs_changed

  serialize :settings, Hash

  state_machine :status, initial: :requested do
    state :requested
    state :active
    state :denied
    state :inactive

    event :approve do
      transition :requested => :active
    end
    after_transition :on => :approve, :do => :notify_user

    event :deny do
      transition :requested => :denied
    end
    after_transition :on => :deny, :do => :notify_user_of_denial

    event :disable do
      transition any => :inactive
    end
  end

  def is_bridge?
    (name =~ /^Bridges at/) != nil
  end

  def interaction_types
    return InteractionType.where(organization_id: [0, id]).order('id')
  end

  def interaction_privacy_settings
    list = Array.new
    list << ["Everyone", "everyone"]
    list << ["Everyone in #{parent.name}", "organization"] if parent.present?
    list << ["Everyone in #{name}", "organization"]
    list << ["Admins in #{name}", "admins"]
    list << ["Me only", "me"]
    return list
  end

  # Push individual weeks of stats to infobase, starting with the first week afeter the last push
  # If the user increased the numbers, push the extra values on the final week
  def push_to_infobase(params)
    start_date = (last_push_to_infobase + 1.day).beginning_of_week(:sunday)
    end_date = last_week
    periods = []
    start_date.step(end_date, 7) do |period_begin|
      period_end = period_begin + 6.days
      period_end = period_end
      stats = {activity_id: importable_id,
               period_begin: period_begin.to_s(:db),
               period_end: period_end.to_s(:db)
              }
      if period_end == end_date
        # Add the group stats and any additional bumps entered
        students_involved = people.students.with_label(Label.involved, self).where("organizational_labels.created_at < ?", period_end).count

        faculty_involved  = people.faculty.with_label(Label.involved, self).where("organizational_labels.created_at < ?", period_end).count

        students_engaged  = people.students.with_label(Label.engaged_disciple, self).where("organizational_labels.created_at < ?", period_end).count

        faculty_engaged   = people.faculty.with_label(Label.engaged_disciple, self).where("organizational_labels.created_at < ?", period_end).count

        student_leaders   = people.students.with_label(Label.leader, self).where("organizational_labels.created_at < ?", period_end).count

        faculty_leaders   = people.faculty.with_label(Label.leader, self).where("organizational_labels.created_at < ?", period_end).count

        spiritual_conversations = params[:spiritual_conversation].to_i -
                                  interactions_count('spiritual_conversation') +
                                  interactions_count('spiritual_conversation', period_begin, period_end)

        personal_evangelism = params[:gospel_presentation].to_i -
                                  interactions_count('gospel_presentation') +
                                  interactions_count('gospel_presentation', period_begin, period_end)

        personal_decisions = params[:prayed_to_receive_christ].to_i -
                                  interactions_count('prayed_to_receive_christ') +
                                  interactions_count('prayed_to_receive_christ', period_begin, period_end)

        holy_spirit_presentations = params[:holy_spirit_presentation].to_i -
                                    interactions_count('holy_spirit_presentation') +
                                    interactions_count('holy_spirit_presentation', period_begin, period_end)

        graduating_on_mission = params[:graduating_on_mission].to_i -
                                  interactions_count('graduating_on_mission') +
                                  interactions_count('graduating_on_mission', period_begin, period_end)

        faculty_on_mission = params[:faculty_on_mission].to_i -
                                  interactions_count('faculty_on_mission') +
                                  interactions_count('faculty_on_mission', period_begin, period_end)

        stats.merge!({students_involved: students_involved,
                      faculty_involved: faculty_involved,
                      students_engaged: students_engaged,
                      faculty_engaged: faculty_engaged,
                      student_leaders: student_leaders,
                      faculty_leaders: faculty_leaders,
                      spiritual_conversations: spiritual_conversations,
                      holy_spirit_presentations: holy_spirit_presentations,
                      personal_evangelism: personal_evangelism,
                      personal_decisions: personal_decisions,
                      graduating_on_mission: graduating_on_mission,
                      faculty_on_mission: faculty_on_mission,
                      group_evangelism: params[:group_evangelism].to_i,
                      group_decisions: params[:group_evangelism_decision].to_i,
                      media_exposures: params[:media_exposure].to_i,
                      media_decisions: params[:media_exposure_decisions].to_i
                    })
        periods << stats
        break
      else
        stats.merge!({students_involved: people.students.with_label(Label.involved, self).where("organizational_labels.created_at < ?", period_end).count,
                      faculty_involved: people.faculty.with_label(Label.involved, self).where("organizational_labels.created_at < ?", period_end).count,
                      students_engaged: people.students.with_label(Label.engaged_disciple, self).where("organizational_labels.created_at < ?", period_end).count,
                      faculty_engaged: people.faculty.with_label(Label.engaged_disciple, self).where("organizational_labels.created_at < ?", period_end).count,
                      student_leaders: people.students.with_label(Label.leader, self).where("organizational_labels.created_at < ?", period_end).count,
                      spiritual_conversations: interactions_count('spiritual_conversation', period_begin, period_end),
                      holy_spirit_presentations: interactions_count('holy_spirit_presentation', period_begin, period_end),
                      personal_evangelism: interactions_count('gospel_presentation', period_begin, period_end),
                      personal_decisions: interactions_count('prayed_to_receive_christ', period_begin, period_end),
                      graduating_on_mission: interactions_count('graduating_on_mission', period_begin, period_end),
                      faculty_on_mission: interactions_count('faculty_on_mission', period_begin, period_end)
                     })
        periods << stats
      end
    end

    # Make sure everything is positive
    periods.each do |period|
      period.each do |k, v|
        if v.is_a?(Integer)
          period[k] = period[k] > 0 ? period[k] : 0
        end
      end
    end

    json = {statistics: periods}.to_json
    RestClient.post(APP_CONFIG['infobase_url'] + '/api/v1/stats', json, content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\"")

    update_attributes(last_push_to_infobase: last_week)
  end

  def last_push_to_infobase
    @last_push_to_infobase ||= self[:last_push_to_infobase]
    unless @last_push_to_infobase
      # check infobase for a stat entry
      begin
        stats = JSON.parse(RestClient.get(APP_CONFIG['infobase_url'] + "/api/v1/stats/activity?activity_id=#{importable_id}&begin_date=#{created_at.to_date.to_s(:db)}&end_date=#{Date.today.to_s(:db)}", content_type: :json, accept: :json, authorization: "Token token=\"#{APP_CONFIG['infobase_token']}\""))
        @last_push_to_infobase = Date.parse(stats['statistics'].last['period_end'])
        update_column(:last_push_to_infobase, @last_push_to_infobase) if @last_push_to_infobase
      rescue
        @last_push_to_infobase = created_at.to_date.end_of_week(:sunday)
      end
    end
    @last_push_to_infobase
  end

  def last_week
    @last_week ||= 1.week.ago.end_of_week(:sunday).to_date
  end

  def interactions_of_type(type, start_date = nil, end_date = nil)
    start_date ||= last_push_to_infobase
    end_date ||= last_week
    interactions.joins(:interaction_type).where("interaction_types.i18n = ? AND interactions.timestamp > ? AND interactions.timestamp <= ?", type, start_date, end_date.end_of_day)
  end

  def interactions_count(type, start_date = nil, end_date = nil)
    interactions_of_type(type, start_date, end_date).count
  end

  def sms_gateway
    return settings[:sms_gateway] if settings[:sms_gateway]
    ancestors.reverse.each do |org|
      return org.settings[:sms_gateway] if org.settings[:sms_gateway].present?
    end
    return 'twilio'
  end

  def pending_transfer
    sent.includes(:sent_person).where('sent_people.id IS NULL')
  end

  def completed_transfer
    sent.includes(:sent_person).where('sent_people.id IS NOT NULL')
  end

  def available_transfer
    contacts - sent
  end

  def has_parent?(org_id)
    if id == org_id
      return true
    elsif !ancestry.present?
      return false
    end
    ancestry.present? ? ancestry.split('/').include?(org_id.to_s) : true
  end

  def is_root? # an org is considered root if it has no parents
    ancestry.nil? || !parent.show_sub_orgs
  end

  def is_child?
    !ancestry.nil?
  end

  def is_root_and_has_only_one_admin?
    (ancestry.nil? || !parent.show_sub_orgs ) && admins.count == 1
  end

  def to_s() name; end

  def parent_organization
    org = Organization.find(ancestry.split('/').last) if ancestry.present?
    return org if org.present?
  end

  def permission_set
    default_permissions + non_default_permissions
  end

  def default_permissions
    permissions.default_permissions
  end

  def non_default_permissions
    permissions.non_default_permissions
  end

  def label_set
    default_labels + non_default_labels
  end

  def default_labels
    if is_bridge?
      labels.default_bridge_labels
    elsif has_parent?(1)
      labels.default_cru_labels
    else
      labels.default_labels
    end
  end

  def non_default_labels
    labels.non_default_labels
  end

  def parent_organization_admins
    #returns own admins plus the all the admins of all the ancestor organizations
    if ancestry.nil? || !parent.show_sub_orgs
      return admins
    else
      return parent.parent_organization_admins + admins
    end
  end

  def all_possible_admins
    admins.present? ? admins : parent_organization_admins
  end

  def all_possible_admins_with_email
    all_admins = all_possible_admins
    if all_admins.present?
      admins_with_email = Array.new
      all_admins.each do |admin|
        admins_with_email << admin if admin.email.present?
      end
      return admins_with_email
    end
  end

  def parents
    ancestry.present? ? Organization.where(id: ancestry.split('/')) : []
  end

  def self_and_parents
    [self] + parents
  end

  def self_and_children
    [self] + children
  end

  def self_and_descendant_ids
    [id] + descendant_ids
  end

  # def children_surveys
  #   Survey.where(organization_id: child_ids)
  # end

  def generate_api_secret
    if api_client
      api_client.assign_code_and_secret
      api_client.save!
    else
      create_api_client(link: "/organizations/#{id}",
                        display_name: to_s)
    end
  end

  def active_keywords
    keywords.where(state: 'active')
  end

  def self_and_children_ids
    [id] + child_ids
  end

  def self_and_children_surveys
    Survey.where(organization_id: self_and_children_ids)
  end

  def self_and_children_keywords
    SmsKeyword.where(organization_id: self_and_children_ids)
  end

  def self_and_children_questions
    @self_and_children_questions ||= self_and_children_surveys.collect(&:questions).flatten.uniq
  end

  def assigned_contacts
    assignments = contact_assignments.where(person_id: contacts.collect(&:id), assigned_to_id: leaders.collect(&:id))
    assignments.present? ? contacts.where(id: assignments.collect(&:person_id)) : contacts
  end

  def assigned_contacts_with_archived
    assignments = contact_assignments.where(person_id: contacts_with_archived.collect(&:id), assigned_to_id: leaders.collect(&:id))
    assignments.present? ? contacts_with_archived.where(id: assignments.collect(&:person_id)) : contacts_with_archived
  end

  def unassigned_contacts
    assignments = contact_assignments.where(person_id: contacts.collect(&:id), assigned_to_id: leaders.collect(&:id))
    assignments.present? ? contacts.where("people.id NOT IN (?)", assignments.collect(&:person_id)) : contacts
  end

  def unassigned_contacts_with_archived
    assignments = contact_assignments.where(person_id: contacts_with_archived.collect(&:id), assigned_to_id: leaders.collect(&:id))
    assignments.present? ? contacts_with_archived.where("people.id NOT IN (?)", assignments.collect(&:person_id)) : contacts_with_archived
  end

  def inprogress_contacts
    Person
    .joins("INNER JOIN organizational_permissions ON organizational_permissions.person_id = people.id
        AND organizational_permissions.organization_id = #{id}
        AND organizational_permissions.permission_id = '#{Permission::NO_PERMISSIONS_ID}'
        AND organizational_permissions.followup_status <> 'do_not_contact'
        AND organizational_permissions.followup_status <> 'completed'
        AND org_permissions.archive_date IS NULL
        LEFT JOIN contact_assignments ON contact_assignments.person_id = people.id
        AND contact_assignments.organization_id = #{id}")
        .where("contact_assignments.assigned_to_id IN (?)", only_leaders)
  end
  def inprogress_contacts_with_archived
    Person
    .joins("INNER JOIN organizational_permissions ON organizational_permissions.person_id = people.id
        AND organizational_permissions.organization_id = #{id}
        AND organizational_permissions.permission_id = '#{Permission::NO_PERMISSIONS_ID}'
        AND organizational_permissions.followup_status <> 'do_not_contact'
        AND organizational_permissions.followup_status <> 'completed'
        LEFT JOIN contact_assignments ON contact_assignments.person_id = people.id
        AND contact_assignments.organization_id = #{id}")
        .where("contact_assignments.assigned_to_id IN (?)", only_leaders)
  end


  def delete_person(person)
    # If this person is only in the current org, delete the person
    if person.organizational_permissions_including_archived.where("organization_id <> ?", id).blank?
      person.destroy
    else
      # Otherwise just delete all their permissions in this org
      organizational_permissions.where(person_id: person.id).destroy_all
      # Delete any contact assignments for this person in this org
      contact_assignments.where(assigned_to_id: person.id).destroy_all
    end
  end

  def permissions
    Permission.order('updated_at')
  end

  def labels
    Label.where("(organization_id = 0 OR organization_id = #{id}) AND (i18n <> 'sent' OR i18n IS NULL)")
  end

  def <=>(other)
    name <=> other.name
  end

  def validation_method_enum # ???
    ['relay']
  end

  def terminology_enum
    Organization.connection.select_values("select distinct(terminology) term from organizations order by term")
  end

  def name_with_keyword_count
    "#{name} (#{keywords.count})"
  end

  def add_permission_to_person(person, permission_id, added_by_id = nil)
    person_id = person.is_a?(Person) ? person.id : person

    Retryable.retryable :times => 5 do
      permission = OrganizationalPermission.where(person_id: person_id, organization_id: id, permission_id: permission_id).first_or_create!(added_by_id: added_by_id)
      permission.update_attributes(archive_date: nil)

      # Assure single permission per organization
      org_permissions = OrganizationalPermission.where(person_id: person_id, organization_id: id)
      org_permissions.where("id <> ?", permission.id).destroy_all

      return permission
    end
  end

  def add_label_to_person(person, label_id, added_by_id = nil)
    person_id = person.is_a?(Person) ? person.id : person
    Retryable.retryable :times => 5 do
      label = OrganizationalLabel.where(person_id: person_id, organization_id: id, label_id: label_id).first_or_create!(added_by_id: added_by_id)
      label.update_attributes(removed_date: nil)
      label
    end
  end

  def add_permissions_to_people(people, permissions)
    people.each do |person|
      permissions.each do |permission|
        add_permission_to_person(person, permission)
      end
    end
  end

  def add_labels_to_people(people, labels)
    people.each do |person|
      labels.each do |label|
        add_label_to_person(person, label)
      end
    end
  end

  def remove_permission_from_person(person, permission_id)
    person_id = person.is_a?(Person) ? person.id : person
    OrganizationalPermission.where(person_id: person_id, organization_id: id, permission_id: permission_id).each { |r| r.update_attributes(archive_date: Time.now) }
  end

  def remove_label_from_person(person, label_id)
    person_id = person.is_a?(Person) ? person.id : person
    OrganizationalLabel.where(person_id: person_id, organization_id: id, label_id: label_id).each do |r|
      r.update_attributes(removed_date: Time.now)
    end
  end

  def remove_permissions_from_people(people, permissions)
    people.each do |person|
      remove_permission_from_person(person, permissions)
    end
  end

  def remove_labels_from_people(people, labels)
    people.each do |person|
      remove_label_from_person(person, labels)
    end
  end

  def add_leader(person, current_person)
    person_id = person.is_a?(Person) ? person.id : person
    begin
      org_leader = OrganizationalPermission.find_or_create_by_person_id_and_organization_id_and_permission_id(person_id, id, Permission::USER_ID, :added_by_id => current_person.id)
      unless org_leader.archive_date.nil?
        org_leader.update_attributes({:added_by_id => current_person.id, :archive_date => nil})
        org_leader.notify_new_leader
      end
    rescue => error
      @save_retry_count =  (@save_retry_count || 5)
      retry if( (@save_retry_count -= 1) > 0 )
      raise error
    end
  end

  def add_contact(person)
    begin
      add_permission_to_person(person, Permission::NO_PERMISSIONS_ID)
    rescue => error
      @save_retry_count =  (@save_retry_count || 5)
      retry if( (@save_retry_count -= 1) > 0 )
      raise error
    end
  end

  def add_admin(person)
    add_permission_to_person(person, Permission::ADMIN_ID)
  end

  def add_user(person)
    add_permission_to_person(person, Permission::USER_ID)
  end

  def remove_people(people)
    people.each do |p|
      remove_person(p)
    end
  end

  def remove_person(person)
    person_id = person.is_a?(Person) ? person.id : person
    organizational_permissions.where(person_id: person_id).each do |ors|
      if(ors.permission_id == Permission::USER_ID)
        # remove contact assignments if this was a leader
        Person.find(ors.person_id).contact_assignments.where(organization_id: id).all.collect(&:destroy)
      end
      remove_permission_from_person(person, ors.permission_id)
    end
  end

  def remove_contact(person)
    remove_permission_from_person(person, Permission::NO_PERMISSIONS_ID)
  end

  def add_involved(person)
    add_label_to_person(person, Label::INVOLVED_ID)
  end

  def remove_leader(person)
    person = person.is_a?(Person) ? person : Person.find(person)
    remove_label_from_person(person, Label::LEADER_ID)
    person.remove_assigned_contacts(self)
  end

  def move_contact(person, to_org, keep_contact, current_admin = nil)
    @followup_comments = followup_comments.where(contact_id: person.id)
    @rejoicables = rejoicables.where(person_id: person.id)

    to_org.add_contact(person)

    if keep_contact == "false"
      # move call followup comments
      @followup_comments.update_all(organization_id: to_org.id)
      @rejoicables.update_all(organization_id: to_org.id)
      delete_person(person)
    else
      # copy followup comments
      @followup_comments.each do |fc|
        to_org.followup_comments.create(fc.attributes.slice(:contact_id, :commenter_id, :status, :comment, :updated_at, :created_at, :deleted_at))
        @rejoicables.where(followup_comment_id: fc.id).each do |r|
          to_org.rejoicables.create(r.attributes.slice(:person_id, :created_by_id, :what, :updated_at, :created_at, :deleted_at))
        end
      end
    end

    # Save transfer log
    val_copy = keep_contact == "false" ? false : true
    val_transferred_by = current_admin.id if current_admin.present?
    PersonTransfer.create(person_id: person.id, old_organization_id: id, new_organization_id: to_org.id, transferred_by_id: val_transferred_by, copy: val_copy)

    FollowupComment.where(organization_id: id, contact_id: person.id).update_all(organization_id: to_org.id)
  end

  def create_admin_user
    add_admin(Person.find(self.person_id)) if person_id
  end

  def notify_admin_of_request
    begin
      if parent
        update_column(:status, 'active')
      else
        OrganizationMailer.enqueue.notify_admin_of_request(self.id)
      end
    rescue ActiveRecord::RecordNotFound
    end
  end

  def notify_new_leader(person, added_by)
    token = SecureRandom.hex(12)
    person.user.remember_token = token
    person.user.remember_token_expires_at = 1.month.from_now
    person.user.save(validate: false)
    LeaderMailer.added(person, added_by, self, token).deliver
  end

  def attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
    admin_ids = parent_organization_admins.collect(&:id)
    i = admin_ids & ids.collect(&:to_i)
    return i if (admin_ids - i).blank?
    false
  end

  def attempting_to_delete_or_archive_current_user_self_as_admin?(ids, current_person)
    return true unless ([current_person.id] & ids.collect(&:to_i)).blank?
    false
  end

  def queue_import_from_conference(user)
    async(:import_from_conference, user.id)
  end

  def implied_involvement_root
    # If there is no parent, or the parent is not set to show sub orgs,
    # this org is the implied root
    return self if !parent || !parent.show_sub_orgs

    # Otherwise, recursively call this method on the parent
    parent.implied_involvement_root
  end

	def group_search(term)
		groups.where("LOWER(name) LIKE ?","%#{term}%").limit(5).uniq
	end

	def permission_search(term)
		permissions.where("LOWER(name) LIKE ?","%#{term}%").limit(5).uniq
	end

	def label_search(term)
		labels.where("LOWER(name) LIKE ?","%#{term}%").limit(5).uniq
	end

  private

  def import_from_conference(user_id)
    user = User.find(user_id)

    CrsImport.new(self, user).import
  end

  def notify_user
    if admins
      OrganizationMailer.enqueue.notify_user(id)
    end
    true
  end

  def notify_user_of_denial
    if admins
      OrganizationMailer.enqueue.notify_user_of_denial(id)
    end
    true
  end

  # When an organization is added or removed, any person associated with that organization needs to
  # have their updated_at column touched to clear their org cache. The hard part is figuring out which
  # people need to be updated
  def touch_people
    # Anyone with an organizational permission directly on this org will get updated by the OrganizationalPermission
    # class, so we only have to worry about implied involvement
    # For implied ivolvement we need to walk up the tree until we find a root org, or an org with
    # show_sub_orgs = false
    relevant_org_ids = implied_involvement_root.self_and_children_ids & path_ids
    Person.joins(:organizational_permissions_including_archived).where('organizational_permissions.organization_id' => relevant_org_ids).update_all("`people`.`updated_at` = '#{Time.now.to_s(:db)}'")
  end

  def touch_people_if_show_sub_orgs_changed
    if changed.include?('show_sub_orgs')
      touch_people
    end
  end
end
