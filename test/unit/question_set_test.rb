require 'test_helper'

class QuestionSetTest < ActiveSupport::TestCase
  context "saving a question set" do
    setup do
      @person = Factory(:person)
      @organization = Factory(:organization)
      @organization.add_contact(@person)

      @survey = Factory(:survey, organization: @organization)
      @element = Factory(:element)
    end

    context "AUTOASSIGN" do
      setup do
        @extra = Hash.new
        @rule = Factory(:rule, rule_code: "AUTOASSIGN")
        @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      end

      should " to group" do
        @extra['type'] = 'group'
        Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)

        group = Factory(:group, organization: @organization)
        group_membership = Factory(:group_membership, group: group, person: @person)

        query = group.group_memberships.where(person_id: @person.id)
        assert_equal 1, query.count
        assert_equal "member", query.first.role
      end

      should " to leader" do
        @extra['type'] = 'leader'
        Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)

        assert ContactAssignment.count
      end

      should " to ministry" do
        @extra['type'] = 'ministry'
        Factory(:question_rule, rule: @rule, survey_element: @survey_element, extra_parameters: @extra)

        assert_equal 1, @organization.all_people.where(id: @person.id).count
      end
    end
  end
end