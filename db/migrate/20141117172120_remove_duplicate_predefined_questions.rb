class RemoveDuplicatePredefinedQuestions < ActiveRecord::Migration
  def up
    survey = Survey.find_by_id(APP_CONFIG['predefined_survey'])
    if survey.present?
      duplicate = 0
      puts "Start Migration: Remove Duplicate Predefined Questions"

      puts "Fetching predefined questions..."
      original_questions = survey.questions

      puts "Fetching duplicated questions..."
      duplicate_questions = Element.where('attribute_name IS NOT NULL AND object_name IS NOT NULL')

      # Exclude the original predefined questions
      duplicate_questions = duplicate_questions.where("id NOT IN (?)", original_questions.collect(&:id))

      duplicate_questions.each do |element|
        if element.predefined?
          original = original_questions.find_by_object_name_and_attribute_name(element.object_name, element.attribute_name)
          if original.present?
            original_id = original.id

            duplicate += 1
            puts "(#{duplicate}) Duplicate found..."

            puts "Updating survey elements..."
            # Update survey_elements
            survey_elements = element.survey_elements
            survey_elements.update_all(element_id: original_id) if survey_elements.present?

            puts "Updating question leaders..."
            # Update question_leaders
            question_leaders = element.question_leaders
            question_leaders.update_all(element_id: original_id) if question_leaders.present?

            puts "Updating answers..."
            # Update answers
            answers = element.answers
            answers.update_all(question_id: original_id) if answers.present?

            puts "Updating custom element labels..."
            # Update custom_element_labels
            custom_labels = element.custom_labels
            custom_labels.update_all(question_id: original_id) if custom_labels.present?

            puts "Deleting duplicate question..."
            # Delete the duplicate element
            element.destroy
            puts " -- "
          end
        end
      end
      puts "Done: #{duplicate} duplicate predefined questions were successfully updated."
    end
  end

  def down
  end
end
