class PageElement < ActiveRecord::Base
  acts_as_list scope: :page_id
  belongs_to :page
  belongs_to :element
  belongs_to :question,
    ->{where("kind NOT IN('Paragraph', 'Section')")}, foreign_key: 'element_id', class_name: 'Element'
end
