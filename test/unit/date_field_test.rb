require 'test_helper'

class DateFieldTest < ActiveSupport::TestCase
  setup do
    @person = Factory(:person)
    @survey = Factory(:survey)
    @element1 = Factory(:element, kind: 'DateField', style: 'date_field')
    @element2 = Factory(:element, kind: 'DateField', style: 'mmyy')
  end
  context "validation_class function" do
    should "return default date validation class" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element1)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      assert_equal "validate-date", @survey.questions.first.validation_class(@answer_sheet).strip
    end
    should "return special date validation class for mmyy format" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element2)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      assert_equal "validate-selection", @survey.questions.first.validation_class(@answer_sheet).strip
    end
  end
  context "ptemplate function" do
    should "return default date field template name" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element1)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      assert_equal "date_field", @survey.questions.first.ptemplate.strip
    end
    should "return special date field template name mmyy format" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element2)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      assert_equal "date_field_mmyy", @survey.questions.first.ptemplate.strip
    end
  end
end
