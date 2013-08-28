class GenerateNewPredefinedQuestions < ActiveRecord::Migration
  def up
    # Clean elements
    Element.where("attribute_name IN (?)", ['faculty','nationality']).delete_all

    # Generate elements
    execute("INSERT INTO `elements` (`kind`, `style`, `label`, `content`, `required`, `slug`, `position`, `object_name`, `attribute_name`, `source`, `value_xpath`, `text_xpath`, `question_grid_id`, `cols`, `is_confidential`, `total_cols`, `css_id`, `css_class`, `created_at`, `updated_at`, `related_question_sheet_id`, `conditional_id`, `tooltip`, `hide_label`, `hide_option_labels`, `max_length`, `web_only`, `trigger_words`, `notify_via`, `hidden`, `crs_question_id`) VALUES ('ChoiceField', 'drop-down', 'Nationality', 'Chinese\nSouth Asian (India, Nepal, Sri Lanka)\nTIP/Muslim\nAmerican\nAll Other Nations', 0, 'nationality', NULL, 'person', 'nationality', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, '2013-08-27 17:52:28', '2013-08-27 17:52:28', NULL, NULL, NULL, 0, 0, NULL, 0, NULL, NULL, 0, NULL), ('ChoiceField', 'radio', 'Are you a faculty?', 'Yes\nNo', 0, 'faculty', NULL, 'person', 'faculty', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, '2013-08-28 16:07:48', '2013-08-28 16:07:48', NULL, NULL, NULL, 0, 0, NULL, 0, NULL, NULL, 0, NULL);");

    # Connect faculty to predefined questions
    faculty_question = Element.find_by_attribute_name('faculty')
    if faculty_question.present?
      SurveyElement.create(survey_id: APP_CONFIG['predefined_survey'], element_id: faculty_question.id)
    end

    # Connect nationality to predefined questions
    nationality_question = Element.find_by_attribute_name('nationality')
    if nationality_question.present?
      SurveyElement.create(survey_id: APP_CONFIG['predefined_survey'], element_id: nationality_question.id)
    end

  end

  def down
    # Get elements
    elements = Element.where("attribute_name IN (?)", ['faculty','nationality'])

    # Clean survey elements
    SurveyElement.where(survey_id: APP_CONFIG['predefined_survey'], element_id: elements.collect(&:id)).delete_all

    # Clean elements
    elements.delete_all
  end
end
