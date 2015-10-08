require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  should have_many(:question_rules)

  context 'get available rules in a survey' do
    setup do
      @person = FactoryGirl.create(:person)
      @survey = FactoryGirl.create(:survey)
      @element1 = FactoryGirl.create(:element)
      @element2 = FactoryGirl.create(:element)
      @rule1 = FactoryGirl.create(:rule, limit_per_survey: 0)
      @rule2 = FactoryGirl.create(:rule, limit_per_survey: 1)
      @rule3 = FactoryGirl.create(:rule, limit_per_survey: 2)
    end
    should 'return all rules if no rules assigned yet' do
      rules = Rule.available_in_survey(@survey)
      assert_equal 3, rules.count
      assert rules.include?(@rule1)
      assert rules.include?(@rule2)
      assert rules.include?(@rule3)
    end
    should 'not return rules with limit 1 if it is already assigned' do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule2, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      assert_equal 2, rules.count
      assert !rules.include?(@rule2)
    end
    should 'return rules with limit 0 even if it is already assigned' do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule1, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      assert_equal 3, rules.count
      assert rules.include?(@rule1)
    end
    should 'return rules with limit 2 if it is assigned once' do
      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule3, survey_element: @survey_element)
      rules = Rule.available_in_survey(@survey)
      # raise rules.collect(&:id).inspect
      assert_equal 3, rules.count
      assert rules.include?(@rule3)
    end
    should 'not return rules with limit 2 if it is assigned twice' do
      @survey_element1 = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = FactoryGirl.create(:survey_element, survey: @survey, element: @element2, position: 1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule3, survey_element: @survey_element1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule3, survey_element: @survey_element2)
      rules = Rule.available_in_survey(@survey)
      assert_equal 2, rules.count
      assert !rules.include?(@rule3)
    end
  end
end
