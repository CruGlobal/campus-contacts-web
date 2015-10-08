require 'test_helper'

class LabelTest < ActiveSupport::TestCase
  setup do
    @person1 = FactoryGirl.create(:person)
    @person2 = FactoryGirl.create(:person)
    @person3 = FactoryGirl.create(:person)

    @organization = FactoryGirl.create(:organization)
    @organization.add_contact(@person1)
    @organization.add_contact(@person2)
    @label0 = FactoryGirl.create(:label, organization_id: 0)
    @label1 = FactoryGirl.create(:label, organization: @organization)
    @label2 = FactoryGirl.create(:label, organization: @organization)
    FactoryGirl.create(:organizational_label, organization: @organization, person: @person1, label: @label0)
    FactoryGirl.create(:organizational_label, organization: @organization, person: @person1, label: @label1)
    FactoryGirl.create(:organizational_label, organization: @organization, person: @person2, label: @label2)

    @other_organization = FactoryGirl.create(:organization)
    @other_label = FactoryGirl.create(:label, organization: @other_organization)
    @other_person = FactoryGirl.create(:person)
    FactoryGirl.create(:organizational_label, organization: @organization, person: @other_person, label: @label0)
    FactoryGirl.create(:organizational_label, organization: @other_organization, person: @other_person, label: @other_label)
  end

  context 'label_contacts_from_org_with_archived method' do
    should 'return labeled people in an organization' do
      results = @label1.label_contacts_from_org_with_archived(@organization)
      assert_equal 1, results.count
      assert results.include?(@person1)
    end
    should 'not return labeled people in other label of an organization' do
      results = @label1.label_contacts_from_org_with_archived(@organization)
      assert !results.include?(@person2)
    end
    should 'return default labeled people within an organization only' do
      results = @label0.label_contacts_from_org_with_archived(@organization)
      assert_equal 1, results.count
      assert results.include?(@person1)
    end
    should 'not return default labeled people from other organization' do
      results = @label0.label_contacts_from_org_with_archived(@organization)
      assert !results.include?(@other_person)
    end
  end
end
