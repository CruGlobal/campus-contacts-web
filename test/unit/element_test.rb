require 'test_helper'

class ElementTest < ActiveSupport::TestCase
  should have_many(:survey_elements)
  should have_many(:surveys)
  should have_many(:question_leaders)
  should have_many(:leaders)
  should belong_to(:question_grid)
  should belong_to(:choice_field)
  
  setup do    
    @person = Factory(:person)
    @survey = Factory(:survey)
    @element1 = Factory(:element)
    @element2 = Factory(:element)
    @element3 = Factory(:element)
  end
  
  context "position function" do
    should "return the element position" do
      @survey_element1 = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey, element: @element2, position: 2)
      assert_equal 1, @element1.position(@survey)
      assert_equal 2, @element2.position(@survey)
    end
    should "return nil when element is not added to a survey" do
      @survey_element1 = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey, element: @element2, position: 2)
      assert_nil @element3.position(@survey)
    end
    should "return nil when survey is not lined to an element" do
      @survey_element1 = Factory(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey, element: @element2, position: 2)
      @other_survey = Factory(:survey)
      assert_nil @element1.position(@other_survey)
    end
  end
  
  context "ptemplate function" do
    should "return default date field template name" do
      @text_element = Factory(:element, kind: 'TextField', style: 'text_field')
      @date_element = Factory(:element, kind: 'DateField', style: 'date_field')
      @survey_element1 = Factory(:survey_element, survey: @survey, element: @text_element, position: 1)
      @survey_element2 = Factory(:survey_element, survey: @survey, element: @date_element, position: 2)
      assert_equal "text_field", @survey.questions.first.class.to_s.underscore
      assert_equal "date_field", @survey.questions.last.class.to_s.underscore
    end
  end
  
  context "duplicate function" do
    setup do
      @element_to_duplicate = Factory(:element, kind: 'TextField', style: 'text_field')
      @old_question = Element.find(@element_to_duplicate.id)
      @other_survey = Factory(:survey)
    end
    should "copy the element and return the new duplicate element" do
      @new_question = @old_question.duplicate(@other_survey)
      assert @new_question
      assert_equal @new_question, Element.last
    end
    should "copy the element with parent QuestionGrid and return the new duplicate element" do
      @parent = Factory(:element, kind: 'QuestionGrid', style: 'question_grid')
      @parent_question = Element.find(@parent)
      
      @new_question = @old_question.duplicate(@other_survey, @parent_question)
      assert @new_question
      assert_equal @parent.id, @new_question.question_grid_id
    end
    should "copy the element with parent QuestionGridWithTotal and return the new duplicate element" do
      @parent = Factory(:element, kind: 'QuestionGridWithTotal', style: 'question_grid')
      @parent_question = Element.find(@parent)
      
      @new_question = @old_question.duplicate(@other_survey, @parent_question)
      assert @new_question
      assert_equal @parent.id, @new_question.question_grid_id
    end
    should "copy the element with parent ChoiceField and return the new duplicate element" do
      @parent = Factory(:element, kind: 'ChoiceField', style: 'choice_field')
      @parent_question = Element.find(@parent)
      
      @new_question = @old_question.duplicate(@other_survey, @parent_question)
      assert @new_question
      assert_equal @parent.id, @new_question.conditional_id
    end
  end
  
  context "reuseable? function" do
    should "return true if element is a QuestionGrid" do
      @element = Factory(:question_grid)
      assert @element.reuseable?
    end
    should "return true if element is a QuestionGridWithTotal" do
      @element = Factory(:question_grid_with_total)
      assert @element.reuseable?
    end
    should "return false if element is a ChoiceField" do
      @element = Factory(:choice_field)
      assert (@element.reuseable?)
    end
  end
  
  context "set_defaults function" do
    should "set default content for choice field" do
      @element = Factory(:choice_field, content: '')
      assert_equal "Choice One\nChoice Two\nChoice Three", @element.content
    end
    should "set default content for paragraph" do
      @element = Factory(:paragraph, content: '')
      assert_equal "Lorem ipsum...", @element.content
    end
    should "set default style for text field" do
      @element = Factory(:text_field, style: '')
      assert_equal "essay", @element.style
    end
    should "set default style for date field" do
      @element = Factory(:date_field, style: '')
      assert_equal "date", @element.style
    end
    should "set default style for paragraph" do
      @element = Factory(:paragraph, style: '')
      assert_equal "paragraph", @element.style
    end
    should "set default style for section" do
      @element = Factory(:section, style: '')
      assert_equal "section", @element.style
    end
    should "set default style for paragraph" do
      @element = Factory(:choice_field, style: '')
      assert_equal "checkbox", @element.style
    end
    should "set default style for question grid" do
      @element = Factory(:question_grid, style: '')
      assert_equal "grid", @element.style
    end
    should "set default style for question grid with total" do
      @element = Factory(:question_grid_with_total, style: '')
      assert_equal "grid_with_total", @element.style
    end
    should "set default style for state chooser" do
      @element = Factory(:state_chooser, style: '')
      assert_equal "state_chooser", @element.style
    end
    should "set default style for reference question" do
      @element = Factory(:reference_question, style: '')
      assert_equal "peer", @element.style
    end
    should "set default style for some_question" do
      @element = Factory(:phone_element, style: '')
      assert_equal "element", @element.style
    end
  end
  
  
end
