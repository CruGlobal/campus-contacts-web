class ContactAssignment < ActiveRecord::Base
  belongs_to :assigned_to, :class_name => "Person", :foreign_key => "assigned_to_id"
  belongs_to :person
  belongs_to :question_sheet
  has_one :keyword, :through => :question_sheet, :source => :questionnable, :class_name => 'SmsKeyword'
  scope :for_sheet, lambda {|q_id| where(:question_sheet_id => q_id)}
end
