require 'test_helper'

class ContactAssignmentTest < ActiveSupport::TestCase
  should "return count assigned to leaders" do
    @org1 = FactoryGirl.create(:organization, name: 'Org 1')
    @org2 = FactoryGirl.create(:organization, name: 'Org 2')
    @leader = FactoryGirl.create(:person, first_name: 'Leader')
    @person1 = FactoryGirl.create(:person)
    @person2 = FactoryGirl.create(:person)
    FactoryGirl.create(:organizational_permission, organization: @org1, person: @person1)
    FactoryGirl.create(:organizational_permission, organization: @org1, person: @person2)
    FactoryGirl.create(:organizational_permission, organization: @org1, person_id: 9, deleted_at: Date.today)
    FactoryGirl.create(:organizational_permission, organization: @org1, person: FactoryGirl.create(:person))

    FactoryGirl.create(:organizational_permission, organization: @org2, person: @person1)
    FactoryGirl.create(:organizational_permission, organization: @org2, person: @person2, archive_date: Date.today)

    FactoryGirl.create(:contact_assignment, organization: @org1, person: @person1, assigned_to: @leader)
    FactoryGirl.create(:contact_assignment, organization: @org1, person: @person2, assigned_to: @leader)
    FactoryGirl.create(:contact_assignment, organization: @org1, person_id: 9, assigned_to: @leader)

    FactoryGirl.create(:contact_assignment, organization: @org2, person: @person1, assigned_to: @leader)
    FactoryGirl.create(:contact_assignment, organization: @org2, person: @person2, assigned_to: @leader)

    results_for_org1 = ContactAssignment.assignment_counts_for([@leader.id, @leader.id + 1], @org1.id, false)
    assert_equal 1, results_for_org1.count
    assert_equal 2, results_for_org1[@leader.id]

    results_for_org2 = ContactAssignment.assignment_counts_for([@leader.id], @org2.id, false)
    assert_equal 1, results_for_org2[@leader.id]

    results_for_org2 = ContactAssignment.assignment_counts_for([@leader.id], @org2.id, true)
    assert_equal 2, results_for_org2[@leader.id]

    @person1.destroy
    results_for_org1 = ContactAssignment.assignment_counts_for([@leader.id], @org1.id, false)
    assert_equal 1, results_for_org1[@leader.id]
  end
end
