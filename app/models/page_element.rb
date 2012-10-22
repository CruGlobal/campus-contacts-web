class PageElement < ActiveRecord::Base
  acts_as_list :scope => :page_id
  belongs_to :page
  belongs_to :element
  belongs_to :question, :conditions => "kind NOT IN('Paragraph', 'Section', 'QuestionGrid', 'QuestionGridWithTotal')", :foreign_key => 'element_id', :class_name => 'Element'
end
