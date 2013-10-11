require 'test_helper'

class LabelTest < ActiveSupport::TestCase

  setup do
    @person1 = Factory(:person)
    @person2 = Factory(:person)
    @person3 = Factory(:person)

    @organization = Factory(:organization)
    @organization.add_contact(@person1)
    @organization.add_contact(@person2)
    @label0 = Factory(:label, organization_id: 0)
    @label1 = Factory(:label, organization: @organization)
    @label2 = Factory(:label, organization: @organization)
    Factory(:organizational_label, organization: @organization, person: @person1, label: @label0)
    Factory(:organizational_label, organization: @organization, person: @person1, label: @label1)
    Factory(:organizational_label, organization: @organization, person: @person2, label: @label2)

    @other_organization = Factory(:organization)
    @other_label = Factory(:label, organization: @other_organization)
    @other_person = Factory(:person)
    Factory(:organizational_label, organization: @organization, person: @other_person, label: @label0)
    Factory(:organizational_label, organization: @other_organization, person: @other_person, label: @other_label)
  end

  context "label_contacts_from_org_with_archived method" do
    should "return labeled people in an organization" do
      results = @label1.label_contacts_from_org_with_archived(@organization)
      assert_equal 1, results.count
      assert results.include?(@person1)
    end
    should "not return labeled people in other label of an organization" do
      results = @label1.label_contacts_from_org_with_archived(@organization)
      assert !results.include?(@person2)
    end
    should "return default labeled people within an organization only" do
      results = @label0.label_contacts_from_org_with_archived(@organization)
      assert_equal 1, results.count
      assert results.include?(@person1)
    end
    should "not return default labeled people from other organization" do
      results = @label0.label_contacts_from_org_with_archived(@organization)
      assert !results.include?(@other_person)
    end
  end
end
