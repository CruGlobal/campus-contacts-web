require 'test_helper'

class SurveyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  context "getting question rules of a survey" do
    setup do
      @survey1 = Factory(:survey)
      @survey2 = Factory(:survey)
      @rule = Factory(:rule)
      @element1 = Factory(:element)
      @element2 = Factory(:element)
    end
    should "return the question rules of survey elements" do
      @survey_element1 = Factory(:survey_element, survey: @survey1, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey1, element: @element2, position: 2)
      @question_rule1 = Factory(:question_rule, rule: @rule, survey_element: @survey_element1)
      @question_rule2 = Factory(:question_rule, rule: @rule, survey_element: @survey_element2)
      results = @survey1.question_rules
      assert_equal(results.count, 2, "return an array of question rules")
      assert(results.include?(@question_rule1), "return the question rule")
      assert(results.include?(@question_rule2), "return the question rule")
    end
    should "not return the question rules of other survey" do
      @survey_element1 = Factory(:survey_element, survey: @survey1, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey2, element: @element2, position: 2)
      @question_rule1 = Factory(:question_rule, rule: @rule, survey_element: @survey_element1)
      @question_rule2 = Factory(:question_rule, rule: @rule, survey_element: @survey_element2)
      results = @survey1.question_rules
      assert_equal(results.count, 1, "return an array of question rules of the survey")
      assert_equal(results.first, @question_rule1, "return the only question rule")
    end
  end
  
  context "checking survey if it have automated assignment rule" do
    setup do
      @survey = Factory(:survey)
      @rule = Factory(:rule)
      @element = Factory(:element)
      @extra = Hash.new
      @extra['type'] = 'group'
      @extra['id'] = '300'
    end
    should "return true if it has autoassign question_rule type = 'group'" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)
      result = @survey.has_assign_rule('group')
      assert_equal("300", result, 'should return extra_parameter[:id]')
    end
    should "return false if it dont have autoassign question_rule type='ministry'" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)
      result = @survey.has_assign_rule('ministry')
      assert_equal(false, result, 'should return false')
    end
    should "return false if it indicates id and it dont have autoassign question_rule type='ministry' and id='100'" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)
      result = @survey.has_assign_rule('ministry',100)
      assert_equal(false, result, 'should return false')
    end
    should "return true if it indicates id and it have autoassign question_rule type='group' and id='300'" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)
      result = @survey.has_assign_rule('group',300)
      assert_equal(true, result, 'should return true')
    end
    should "return false if no rules found" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      result = @survey.has_assign_rule('group')
      assert_equal(result, false, 'should return false')
    end
    should "return false if question rule dont have parameters" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: "")
      result = @survey.has_assign_rule('group')
      assert_equal(result, false, 'should return false')
    end
  end
  
  
  context "checking survey if it have applied automated assignment rule to an answer" do
    setup do
      @person = Factory(:person)
      @survey = Factory(:survey)
      @rule = Factory(:rule)
      @element = Factory(:element)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      @extra = Hash.new
      @extra['type'] = 'group'
      @extra['id'] = '300'
      @triggers = 'yes, sure, ok'
    end
    should "return true if it has autoassign question_rule type = 'group' and triggered" do
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: @extra, trigger_keywords: @triggers)
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, true, 'should return true')
    end
    should "return false if it has autoassign question_rule type = 'group' but not triggered" do
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'fine')
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: @extra, trigger_keywords: @triggers)
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, false, 'should return false')
    end
    should "return false if it has autoassign question_rule type = 'group' but triggers is blank" do
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: @extra, trigger_keywords: '')
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, false, 'should return false')
    end
    should "return false if it has autoassign question_rule type = 'group' but no answer yet" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: @extra, trigger_keywords: @triggers)
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, false, 'should return false')
    end
    should "return false if it has autoassign question_rule type = 'group' but survey element is missing" do
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: @extra, trigger_keywords: @triggers)
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, false, 'should return false')
    end
    should "return false if it has autoassign question_rule type = 'group' but extra parameters is blank" do
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element, 
        extra_parameters: '', trigger_keywords: @triggers)
      result = @survey.has_assign_rule_applied(@answer_sheet, 'group')
      assert_equal(result, false, 'should return false')
    end
  end
  
  
end
