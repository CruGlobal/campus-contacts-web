class SurveyElement < ActiveRecord::Base
  set_table_name "mh_survey_elements"
  acts_as_list :scope => :survey_id
  belongs_to :survey
  belongs_to :element
  belongs_to :question, :conditions => "kind NOT IN('Paragraph', 'Section', 'QuestionGrid', 'QuestionGridWithTotal')", :foreign_key => 'element_id', :class_name => 'Element'
end
