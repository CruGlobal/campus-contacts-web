class FollowupComment < ActiveRecord::Base
  belongs_to :contact, :class_name => "Person", :foreign_key => "contact_id"
  belongs_to :commenter, :class_name => "Person", :foreign_key => "commenter_id"
  belongs_to :organization
  has_many :rejoicables, inverse_of: :followup_comment
  # accepts_nested_attributes_for :rejoicables, :reject_if => proc { |obj| obj.what.blank? }
  
end
