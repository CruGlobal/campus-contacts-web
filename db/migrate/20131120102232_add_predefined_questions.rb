class Element < ActiveRecord::Base
end
class SurveyElement < ActiveRecord::Base
end
class AddPredefinedQuestions < ActiveRecord::Migration
  def up
    question_faculty = Element.where(attribute_name: 'faculty').first
    nationality_faculty = Element.where(attribute_name: 'nationality').first
    SurveyElement.where(element_id: question_faculty.id, survey_id: ENV.fetch('PREDEFINED_SURVEY')).first_or_create
    SurveyElement.where(element_id: nationality_faculty.id, survey_id: ENV.fetch('PREDEFINED_SURVEY')).first_or_create
  end

  def down
  end
end
