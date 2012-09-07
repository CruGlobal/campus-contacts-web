require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  should have_many(:question_rules)
  
  context "get available rules in a survey" do
    setup do    
      @person = Factory(:person)
      @survey = Factory(:survey)
      @element1 = Factory(:element)
      @element2 = Factory(:element)
      @rule1 = Factory(:rule, limit_per_survey: 0)
      @rule2 = Factory(:rule, limit_per_survey: 1)
      @rule3 = Factory(:rule, limit_per_survey: 2)
    end
    should "return all rules if no rules assigned yet" do
      rules = Rule.available_in_survey(@survey)
      assert_equal 3, rules.count
      assert rules.include?(@rule1)
      assert rules.include?(@rule2)
      assert rules.include?(@rule3)
    end
    should "not return rules with limit 1 if it is already assigned" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule2, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      assert_equal 2, rules.count
      assert !rules.include?(@rule2)
    end
    should "return rules with limit 0 even if it is already assigned" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule1, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      assert_equal 3, rules.count
      assert rules.include?(@rule1)
    end
    should "return rules with limit 2 if it is assigned once" do
      @survey_element = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule3, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      assert_equal 3, rules.count
      assert rules.include?(@rule3)
    end
    should "not return rules with limit 2 if it is assigned twice" do
      @survey_element1 = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey, element: @element2, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule3, survey_element: @survey_element1)
      @question_rule = Factory(:question_rule, rule: @rule3, survey_element: @survey_element2)
      rules = Rule.available_in_survey(@survey)
      assert_equal 2, rules.count
      assert !rules.include?(@rule3)
    end
  end
  
  
end
