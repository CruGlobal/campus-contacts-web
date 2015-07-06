require 'test_helper'

class ElementTest < ActiveSupport::TestCase
  should have_many(:survey_elements)
  should have_many(:surveys)
  should have_many(:question_leaders)
  should have_many(:leaders)
  should belong_to(:choice_field)

  setup do
    @person = FactoryGirl.create(:person)
    @survey = FactoryGirl.create(:survey)
    @element1 = FactoryGirl.create(:element)
    @element2 = FactoryGirl.create(:element)
    @element3 = FactoryGirl.create(:element)
  end

  context "position function" do
    should "return the element position" do
      @survey_element1 = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = FactoryGirl.create(:survey_element, survey: @survey, element: @element2, position: 2)
      assert_equal 1, @element1.position(@survey)
      assert_equal 2, @element2.position(@survey)
    end
    should "return nil when element is not added to a survey" do
      @survey_element1 = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = FactoryGirl.create(:survey_element, survey: @survey, element: @element2, position: 2)
      assert_nil @element3.position(@survey)
    end
    should "return nil when survey is not lined to an element" do
      @survey_element1 = FactoryGirl.create(:survey_element, survey: @survey, element: @element1, position: 1)
      @survey_element2 = FactoryGirl.create(:survey_element, survey: @survey, element: @element2, position: 2)
      @other_survey = FactoryGirl.create(:survey)
      assert_nil @element1.position(@other_survey)
    end
  end

  context "ptemplate function" do
    should "return default date field template name" do
      @text_element = FactoryGirl.create(:element, kind: 'TextField', style: 'text_field')
      @date_element = FactoryGirl.create(:element, kind: 'DateField', style: 'date_field')
      @survey_element1 = FactoryGirl.create(:survey_element, survey: @survey, element: @text_element, position: 1)
      @survey_element2 = FactoryGirl.create(:survey_element, survey: @survey, element: @date_element, position: 2)
      assert_equal "text_field", @survey.questions.first.class.to_s.underscore
      assert_equal "date_field", @survey.questions.last.class.to_s.underscore
    end
  end

  # context "duplicate function" do
  #   setup do
  #     @element_to_duplicate = FactoryGirl.create(:element, kind: 'TextField', style: 'text_field')
  #     @old_question = Element.find(@element_to_duplicate.id)
  #     @other_survey = FactoryGirl.create(:survey)
  #   end
  #   should "copy the element and return the new duplicate element" do
  #     @new_question = @old_question.duplicate(@other_survey)
  #     assert @new_question
  #     assert_equal @new_question, Element.last
  #   end
  #   should "copy the element with parent QuestionGrid and return the new duplicate element" do
  #     @parent = FactoryGirl.create(:element, kind: 'QuestionGrid', style: 'question_grid')
  #     @parent_question = Element.find(@parent)
  #
  #     @new_question = @old_question.duplicate(@other_survey, @parent_question)
  #     assert @new_question
  #     assert_equal @parent.id, @new_question.question_grid_id
  #   end
  #   should "copy the element with parent QuestionGridWithTotal and return the new duplicate element" do
  #     @parent = FactoryGirl.create(:element, kind: 'QuestionGridWithTotal', style: 'question_grid')
  #     @parent_question = Element.find(@parent)
  #
  #     @new_question = @old_question.duplicate(@other_survey, @parent_question)
  #     assert @new_question
  #     assert_equal @parent.id, @new_question.question_grid_id
  #   end
  #   should "copy the element with parent ChoiceField and return the new duplicate element" do
  #     @parent = FactoryGirl.create(:element, kind: 'ChoiceField', style: 'choice_field')
  #     @parent_question = Element.find(@parent)
  #
  #     @new_question = @old_question.duplicate(@other_survey, @parent_question)
  #     assert @new_question
  #     assert_equal @parent.id, @new_question.conditional_id
  #   end
  # end
  #
  # context "reuseable? function" do
  #   should "return true if element is a QuestionGrid" do
  #     @element = FactoryGirl.create(:question_grid)
  #     assert @element.reuseable?
  #   end
  #   should "return true if element is a QuestionGridWithTotal" do
  #     @element = FactoryGirl.create(:question_grid_with_total)
  #     assert @element.reuseable?
  #   end
  #   should "return false if element is a ChoiceField" do
  #     @element = FactoryGirl.create(:choice_field)
  #     assert (@element.reuseable?)
  #   end
  # end
  #
  # context "set_defaults function" do
  #   should "set default content for choice field" do
  #     @element = FactoryGirl.create(:choice_field, content: '')
  #     assert_equal "Choice One\nChoice Two\nChoice Three", @element.content
  #   end
  #   should "set default content for paragraph" do
  #     @element = FactoryGirl.create(:paragraph, content: '')
  #     assert_equal "Lorem ipsum...", @element.content
  #   end
  #   should "set default style for text field" do
  #     @element = FactoryGirl.create(:text_field, style: '')
  #     assert_equal "essay", @element.style
  #   end
  #   should "set default style for date field" do
  #     @element = FactoryGirl.create(:date_field, style: '')
  #     assert_equal "date", @element.style
  #   end
  #   should "set default style for paragraph" do
  #     @element = FactoryGirl.create(:paragraph, style: '')
  #     assert_equal "paragraph", @element.style
  #   end
  #   should "set default style for section" do
  #     @element = FactoryGirl.create(:section, style: '')
  #     assert_equal "section", @element.style
  #   end
  #   should "set default style for paragraph" do
  #     @element = FactoryGirl.create(:choice_field, style: '')
  #     assert_equal "checkbox", @element.style
  #   end
  #   should "set default style for question grid" do
  #     @element = FactoryGirl.create(:question_grid, style: '')
  #     assert_equal "grid", @element.style
  #   end
  #   should "set default style for question grid with total" do
  #     @element = FactoryGirl.create(:question_grid_with_total, style: '')
  #     assert_equal "grid_with_total", @element.style
  #   end
  #   should "set default style for state chooser" do
  #     @element = FactoryGirl.create(:state_chooser, style: '')
  #     assert_equal "state_chooser", @element.style
  #   end
  #   should "set default style for reference question" do
  #     @element = FactoryGirl.create(:reference_question, style: '')
  #     assert_equal "peer", @element.style
  #   end
  #   should "set default style for some_question" do
  #     @element = FactoryGirl.create(:phone_element, style: '')
  #     assert_equal "element", @element.style
  #   end
  # end


end
