class FollowupComment < ActiveRecord::Base
  belongs_to :contact, :class_name => "Person", :foreign_key => "contact_id"
  belongs_to :commenter, :class_name => "Person", :foreign_key => "commenter_id"
  belongs_to :organization
  has_many :rejoicables, inverse_of: :followup_comment
  # accepts_nested_attributes_for :rejoicables, :reject_if => proc { |obj| obj.what.blank? }
  
  def to_hash
    hash = {}
    hash['id'] = id
    hash['contact_id'] = contact_id
    hash['commenter_id'] = commenter_id
    hash['comment'] = comment
    hash['status'] = status
    hash['organization_id'] = organization_id
    hash['created_at'] = created_at
    hash['created_by_picture_url'] = Person.find(commenter_id).picture
    hash
  end
end
