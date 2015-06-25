require 'test_helper'

class DateFieldTest < ActiveSupport::TestCase
  setup do
    @person = FactoryGirl.create(:person)
    @survey = FactoryGirl.create(:survey)
    @element1 = FactoryGirl.create(:element, kind: 'DateField', style: 'date_field')
    @element2 = FactoryGirl.create(:element, kind: 'DateField', style: 'mmyy')
  end
  context "validation_class function" do
    should "return default date validation class" do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element1)
      @answer_sheet = FactoryGirl.create(:answer_sheet, person: @person, survey: @survey)
      assert_equal "validate-date", @survey.questions.first.validation_class(@answer_sheet).strip
    end
    should "return special date validation class for mmyy format" do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element2)
      @answer_sheet = FactoryGirl.create(:answer_sheet, person: @person, survey: @survey)
      assert_equal "validate-selection", @survey.questions.first.validation_class(@answer_sheet).strip
    end
  end
  context "ptemplate function" do
    should "return default date field template name" do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element1)
      @answer_sheet = FactoryGirl.create(:answer_sheet, person: @person, survey: @survey)
      assert_equal "date_field", @survey.questions.first.ptemplate.strip
    end
    should "return special date field template name mmyy format" do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element2)
      @answer_sheet = FactoryGirl.create(:answer_sheet, person: @person, survey: @survey)
      assert_equal "date_field_mmyy", @survey.questions.first.ptemplate.strip
    end
  end
end
