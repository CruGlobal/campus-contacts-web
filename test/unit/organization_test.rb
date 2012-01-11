require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  
  should have_many(:roles)
  should have_many(:group_labels)
  should have_many(:activities)
  should have_many(:target_areas)
  should have_many(:organization_memberships)
  should have_many(:people)
  should have_many(:contact_assignments)
  should have_many(:keywords)
  should have_many(:surveys)
  should have_many(:survey_elements)
  should have_many(:questions)
  should have_many(:all_questions)
  should have_many(:followup_comments)
  should have_many(:organizational_roles)
  should have_many(:leaders)
  should have_many(:admins)
  should have_many(:all_contacts)
  should have_many(:contacts)
  should have_many(:dnc_contacts)
  should have_many(:completed_contacts)
  should have_many(:inprogress_contacts)
  should have_many(:no_activity_contacts)
  should have_many(:rejoicables)
  should have_many(:groups)

  context "an organization" do

    should "delete suborganizations when deleted" do
      org1 = Factory(:organization)
      org2 = Factory(:organization, :parent => org1)
      org3 = Factory(:organization, :parent => org2)

      assert_difference("Organization.count", -3, "Organizations were not deleted after parent was destroyed.") do 
        org1.destroy
      end
    end

    should "have both name and terminology" do

      assert_difference("Organization.count", 0, "An organization was created despite the absence of terminology") do
        Organization.create(:name => "name")
      end

      assert_difference("Organization.count", 0, "An organization was created despite the absence of name") do
        Organization.create(:terminology => "termi")
      end
      
    end
=begin
    should "have at least one parent after creation" do
      org = Factory(:organization)
      assert_not_nil org.parent
    end
=end
  end

  test "self and children ids" do
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)

    assert_equal org1.self_and_children_ids.sort{ |a, b| 1*(b <=> a) }, [org1.id, org2.id].sort{ |a, b| 1*(b <=> a) }, "Parent organization did not return correct self and children ids"
    #[2, 3, 1].sort{ |a, b| 1*(b <=> a) } == [2, 1, 3].sort{ |a, b| 1*(b <=> a) }    
  end

  test "self and children surveys" do
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)
    survey1 = Factory(:survey, :organization => org1)
    survey2 = Factory(:survey, :organization => org2)

    assert_equal org1.self_and_children_surveys.sort{ |a, b| 1*(b <=> a) }, [survey1, survey2].sort{ |a, b| 1*(b <=> a) }, "Parent organization did not return correct self and children surveys"
  end

  test "self and children keywords" do
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)
    keyword1 = Factory(:sms_keyword, :organization => org1)
    keyword2 = Factory(:sms_keyword, :organization => org2)

    assert_equal org1.self_and_children_keywords.sort{ |a, b| 1*(b <=> a) }, [keyword1, keyword2].sort{ |a, b| 1*(b <=> a) }, "Parent organization did not return correct self and children keywords"
  end

  
  test "self and children questions" do #this test is not done
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)
    survey1 = Factory(:survey, :organization => org1)
    survey2 = Factory(:survey, :organization => org2)

    puts org1.self_and_children_questions

    #assert_equal org1.self_and_children_keywords.sort{ |a, b| 1*(b <=> a) }, [keyword1, keyword2].sort{ |a, b| 1*(b <=> a) }, "Parent organization did not return correct self and children keywords"
  end

  test "terminology enum" do
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)

    assert_equal org1.terminology_enum.sort{ |a, b| 1*(b <=> a) }, [org1.terminology, org2.terminology].uniq.sort{ |a, b| 1*(b <=> a) }, "Organization class did not return correct unique terminologies"
  end

  test "roles" do
    org1 = Factory(:organization)
    role1 = Factory(:role, :organization => org1)
    a = Role.where("organization_id = 0")
    a << role1
    
    assert_equal org1.roles.sort{ |a, b| 1*(b <=> a) }, a.uniq.sort{ |a, b| 1*(b <=> a) }, "Organization class did not return correct roles"
  end

  test "add initial admin after creating an org" do
    person = Factory(:person)
    assert_difference "OrganizationalRole.count", 1 do
      Factory(:organization, person_id: person.id)
    end
  end


  
  # Replace this with your real tests.
=begin
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
=end
  
end
