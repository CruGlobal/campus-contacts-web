class FollowupComment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  attr_accessible :contact_id, :commenter_id, :comment, :status, :organization_id, :deleted_at

  belongs_to :contact, class_name: 'Person', foreign_key: 'contact_id'
  belongs_to :commenter, class_name: 'Person', foreign_key: 'commenter_id'
  belongs_to :organization
  has_many :rejoicables, inverse_of: :followup_comment, dependent: :destroy
  accepts_nested_attributes_for :rejoicables, reject_if: proc { |attributes| attributes[:what].blank? }, allow_destroy: true
  after_create :update_followup_status

  default_scope -> { where(deleted_at: nil) }

  def to_hash
    hash = {}
    hash['id'] = id
    hash['contact_id'] = contact_id
    commenter = Person.find(commenter_id)
    hash['commenter'] = { id: commenter_id, name: commenter.to_s, picture: commenter.picture }
    hash['comment'] = comment
    hash['status'] = status
    hash['organization_id'] = organization_id
    hash['created_at'] = created_at.utc.to_s
    hash['created_at_words'] = time_ago_in_words(created_at) + ' ago'
    hash['updated_at'] = updated_at.utc.to_s
    hash['deleted_at'] = deleted_at.utc.to_s unless deleted_at.nil?
    hash
  end

  def destroy
    run_callbacks :destroy do
      update_attribute(:updated_at, DateTime.now)
      update_attribute(:deleted_at, DateTime.now)
    end
  end

  def delete
    run_callbacks :delete do
      update_attribute(:updated_at, DateTime.now)
      update_attribute(:deleted_at, DateTime.now)
    end
  end

  def self.create_from_survey(organization, person, questions, answer_sheet, status = nil, timestamp = nil)
    timestamp ||= Time.now
    answer_sheets = Array.wrap(answer_sheet)
    answer_sheets.each(&:reload)
    status ||= OrganizationalPermission::FOLLOWUP_STATUSES.first
    answers = questions.collect do |q|
      sheet = answer_sheets.detect { |as| q.display_response(as).present? }
      "#{q.label} #{q.display_response(sheet)}" if sheet
    end
    comment = answers.compact.uniq.join("\n")
    unless comment.blank?
      create!(contact_id: person.id, commenter_id: person.id, organization_id: organization.id, comment: comment, status: status, created_at: timestamp)
    end
  end

  private

  def update_followup_status
    person = Person.find_by(id: contact_id)
    organization = Organization.find_by(id: organization_id)
    if person.present? && organization.present?
      org_permission = person.organizational_permission_for_org(organization)
      if org_permission.present? && org_permission.permission_id == Permission::NO_PERMISSIONS_ID
        org_permission.update_attribute(:followup_status, status)
      end
    end
  end
end
