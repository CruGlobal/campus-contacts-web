class Element < ActiveRecord::Base
end
class ChangeFacultyElementLabel < ActiveRecord::Migration
  def up
    question_faculty = Element.where(attribute_name: 'faculty').first
    question_faculty.update_attribute(:label, "Are you faculty?") if question_faculty.present?
  end

  def down
  end
end
