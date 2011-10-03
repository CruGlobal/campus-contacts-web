require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "move contact" do
    person = Factory(:person_with_things)
    contact = Factory(:person)
    org1 = Factory(:organization)
    org2 = Factory(:organization)
    org1.add_contact(contact)
    org1.add_admin(person)
    FollowupComment.create(contact_id: contact.id, commenter_id: person.id, organization_id: org1.id, comment: 'test', status: 'contacted')
    org1.move_contact(contact, org2)
    assert_equal(0, org1.contacts.length)
    assert_equal(1, org2.contacts.length)
    assert_equal(0, FollowupComment.where(contact_id: contact.id, organization_id: org1.id).count)
    assert_equal(1, FollowupComment.where(contact_id: contact.id, organization_id: org2.id).count)
  end
end
