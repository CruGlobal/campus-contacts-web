class Element < ActiveRecord::Base
end
class ChangeFacultyElementLabel < ActiveRecord::Migration
  def up
    question_faculty = Element.find_by_attribute_name('faculty')
    question_faculty.update_attribute(:label, "Are you faculty?") if question_faculty.present?
  end

  def down
  end
end
