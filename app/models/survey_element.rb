class SurveyElement < ActiveRecord::Base
  acts_as_list :scope => :survey_id
  belongs_to :survey
  belongs_to :element
  belongs_to :question, :conditions => "kind NOT IN('Paragraph', 'Section')", :foreign_key => 'element_id', :class_name => 'Element'
  has_many :question_rules
  has_many :rules, :through => :question_rules
  validates_uniqueness_of :element_id, :scope => :survey_id, message: "You cannot assign a question twice in a survey!" # a question element cannot be on the same survey twice!
end
