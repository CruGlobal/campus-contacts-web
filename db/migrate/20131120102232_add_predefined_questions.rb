class Element < ActiveRecord::Base
end
class SurveyElement < ActiveRecord::Base
end
class AddPredefinedQuestions < ActiveRecord::Migration
  def up
    question_faculty = Element.find_by_attribute_name('faculty')
    nationality_faculty = Element.find_by_attribute_name('nationality')
    SurveyElement.find_or_create_by_element_id_and_survey_id(question_faculty.id, APP_CONFIG['predefined_survey'])
    SurveyElement.find_or_create_by_element_id_and_survey_id(nationality_faculty.id, APP_CONFIG['predefined_survey'])
  end

  def down
  end
end
