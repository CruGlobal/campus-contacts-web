require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  should have_many(:group_labels)
  should have_many(:activities)
  should have_many(:target_areas)
  should have_many(:people)
  should have_many(:contact_assignments)
  should have_many(:keywords)
  should have_many(:surveys)
  should have_many(:survey_elements)
  should have_many(:questions)
  should have_many(:all_questions)
  should have_many(:followup_comments)
  should have_many(:organizational_permissions)
  should have_many(:leaders)
  should have_many(:users)
  should have_many(:only_users)
  should have_many(:admins)
  should have_many(:all_people)
  should have_many(:all_people_with_archived)
  should have_many(:contacts)
  should have_many(:dnc_contacts)
  should have_many(:completed_contacts)
  should have_many(:no_activity_contacts)
  should have_many(:rejoicables)
  should have_many(:groups)

  # begin methods testing

  context "get all people" do
    setup do
      @org1 = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)

      Factory(:organizational_permission, person: @person2, permission: Permission.no_permissions, organization: @org1, :added_by_id => @person1.id)
      Factory(:organizational_permission, person: @person3, permission: Permission.no_permissions, organization: @org1, :added_by_id => @person1.id)
    end

    should "only get people with some permissions not yet deleted" do
      assert_equal [@person2, @person3], @org1.people
    end
  end

  context "get all leaders" do
    setup do
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)
      @person = Factory(:person)
      @leader1 = Factory(:person, email: 'leader1@email.com')
      @leader2 = Factory(:person, email: 'leader2@email.com')
      @leader3 = Factory(:person, email: 'leader3@email.com')
      @contact = Factory(:person)
      Factory(:organizational_permission, person: @contact, permission: Permission.no_permissions, organization: @org1, :added_by_id => @person.id)
      Factory(:organizational_permission, person: @leader1, permission: Permission.user, organization: @org1, :added_by_id => @person.id)
      Factory(:organizational_permission, person: @leader2, permission: Permission.user, organization: @org1, :added_by_id => @person.id)
      Factory(:organizational_permission, person: @leader3, permission: Permission.user, organization: @org2, :added_by_id => @person.id)
    end
    should "return all leader of an org" do
      results = @org1.users
      assert_equal(2, results.count, "leaders returned should be 2")
      assert(results.include?(@leader1), "should should be returned")
      assert(results.include?(@leader2), "should should be returned")
    end
    should "not return leaders from other org" do
      results = @org1.users
      assert(!results.include?(@leader3), "should not should be returned")
    end
    should "not return non-leaders organizational permission" do
      results = @org1.users
      assert(!results.include?(@contact), "should not should be returned")
    end
  end

  context "parent_organization method" do
    setup do
      @org1 = Factory(:organization, id: '1')
      @org2 = Factory(:organization, id: '2', ancestry: '1')
      @org3 = Factory(:organization, id: '3', ancestry: '1/2')
    end
    should "return the ancestor of the org" do
      assert_equal(@org2, @org3.parent_organization, "org2 should be the parent of org3")
    end
    should "return nil if org do not have ancestor" do
      assert_nil(@org1.parent_organization, "org1 should not have parent org")
    end
  end

  context "parent_organization_admins method" do
    setup do
      @person1 = Factory(:person, :email => "person1@email.com")
      @person2 = Factory(:person, :email => "person2@email.com")
      @person3 = Factory(:person, :email => "person3@email.com")
      @person4 = Factory(:person, :email => "person4@email.com")
      @person5 = Factory(:person, :email => "person5@email.com")
      @person6 = Factory(:person, :email => "person6@email.com")
      @org1 = Factory(:organization, id: '1')
      @org2 = Factory(:organization, id: '2', ancestry: '1')
      @org3 = Factory(:organization, id: '3', ancestry: '1/2')
      @org4 = Factory(:organization, id: '4', ancestry: '1/2/3', show_sub_orgs: false)
      @org5 = Factory(:organization, id: '5', ancestry: '1/2/3/4')
      @org6 = Factory(:organization, id: '6', ancestry: '1/2/3/4/5')
    end

    should "return the admins of org1" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org1, person: @person2, permission: Permission.admin)
      assert @org1.parent_organization_admins.include?(@person1)
      assert @org1.parent_organization_admins.include?(@person2)
    end

    should "return the admins of org2" do
      Factory(:organizational_permission, organization: @org2, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      results = @org3.parent_organization_admins
      assert_equal(2, results.count, "when org3 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
    end

    should "return the admins of org3" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      assert_equal @org3.parent_organization_admins, [@person1, @person2, @person3]
    end

    should "return the admins of org4" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org4, person: @person4, permission: Permission.admin)
      assert_equal @org4.parent_organization_admins, [@person1, @person2, @person3, @person4]
    end

    should "return the admins of org5" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org4, person: @person4, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org5, person: @person5, permission: Permission.admin)
      assert_equal @org5.parent_organization_admins, [@person5]
    end

    should "return the admins of org6" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org4, person: @person4, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org5, person: @person5, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org6, person: @person6, permission: Permission.admin)
      assert_equal @org6.parent_organization_admins, [@person5, @person6]
    end

    should "return the admins of org1 if @org2 dont have admins" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      results = @org3.parent_organization_admins
      assert_equal(1, results.count, "when org3 and org2 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
    end
  end

  context "all_possible_admins method" do
    setup do
      @person1 = Factory(:person, :email => "person1@email.com")
      @person2 = Factory(:person, :email => "person2@email.com")
      @person3 = Factory(:person, :email => "person3@email.com")
      @person4 = Factory(:person, :email => "person4@email.com")
      @org1 = Factory(:organization, id: '1')
      @org2 = Factory(:organization, id: '2', ancestry: '1')
      @org3 = Factory(:organization, id: '3', ancestry: '1/2')
    end
    should "return the admins of org3" do
      Factory(:organizational_permission, organization: @org3, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person2, permission: Permission.admin)
      results = @org3.all_possible_admins
      assert_equal(2, results.count, "when org3 have admins")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
    end
    should "return the admins of org2" do
      Factory(:organizational_permission, organization: @org2, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person3, permission: Permission.admin)
      results = @org3.all_possible_admins
      assert_equal(3, results.count, "when org3 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
      assert(results.include?(@person3), "person3 should be returned")
    end
    should "return the admins of org1" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org1, person: @person2, permission: Permission.admin)
      results = @org3.all_possible_admins
      assert_equal(2, results.count, "when org3 and org2 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
    end
    should "return null" do
      results = @org3.all_possible_admins
      assert_blank(results, "when org3 and org2 and org1 dont have admins")
    end
  end

  context "all_possible_admins_with_email method" do
    setup do
      @person1 = Factory(:person, :email => "person1@email.com")
      @person2 = Factory(:person, :email => "person2@email.com")
      @person3 = Factory(:person)
      @person4 = Factory(:person)
      @org1 = Factory(:organization, id: '1')
      @org2 = Factory(:organization, id: '2', ancestry: '1')
      @org3 = Factory(:organization, id: '3', ancestry: '1/2')
    end
    should "return the admins with email of org3" do
      Factory(:organizational_permission, organization: @org3, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      results = @org3.all_possible_admins_with_email
      assert_equal(1, results.count, "when org3 have admins")
      assert(results.include?(@person1), "person1 should be returned")
    end
    should "return the admins of org2" do
      Factory(:organizational_permission, organization: @org2, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org2, person: @person3, permission: Permission.admin)
      results = @org3.all_possible_admins_with_email
      assert_equal(2, results.count, "when org3 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
    end
    should "return the admins of org1" do
      Factory(:organizational_permission, organization: @org1, person: @person1, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org1, person: @person2, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org1, person: @person3, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org1, person: @person4, permission: Permission.admin)
      results = @org3.all_possible_admins_with_email
      assert_equal(2, results.count, "when org3 and org2 dont have admin")
      assert(results.include?(@person1), "person1 should be returned")
      assert(results.include?(@person2), "person2 should be returned")
    end
    should "return null" do
      results = @org3.all_possible_admins_with_email
      assert_nil(results, "when org3 and org2 and org1 dont have admins")
    end
    should "return null if no admin has email" do
      Factory(:organizational_permission, organization: @org3, person: @person3, permission: Permission.admin)
      Factory(:organizational_permission, organization: @org3, person: @person4, permission: Permission.admin)
      results = @org3.all_possible_admins_with_email
      assert_equal(0, results.count, "when org3 and org2 and org1 dont have admins")
    end
  end

  test "test to_s()" do # Every model, in this application, should return .name of the record
    org1 = Factory(:organization, :name => "Chupakabra")
    assert_equal org1.to_s, "Chupakabra", "Organization did not return correct value on to_s method"
  end

  test "self and children" do

  end

	test "only_leaders should only return people with leader permissions not people with admin permissions but does not have leader permissions" do
    @org = Factory(:organization)
    person1 = Factory(:person, :email => "person1@email.com")
    person2 = Factory(:person, :email => "person2@email.com")
    person3 = Factory(:person, :email => "person3@email.com")
		Factory(:organizational_permission, organization: @org, person: person1, permission: Permission.admin)
		Factory(:organizational_permission, organization: @org, person: person2, permission: Permission.user)
		Factory(:organizational_permission, organization: @org, person: person3, permission: Permission.admin)
		Factory(:organizational_permission, organization: @org, person: person3, permission: Permission.user)
		@org.leaders.inspect
	end

  test "self and children ids" do
    org1 = Factory(:organization)
    org2 = org1.children.create!(name: 'foo', terminology: 'foo')

    assert_equal [org1.id, org2.id].to_set, org1.self_and_children_ids.to_set, "Parent organization did not return correct self and children ids"
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

    assert_equal org1.self_and_children_keywords.to_set, [keyword1, keyword2].to_set, "Parent organization did not return correct self and children keywords"
  end

  test "self and children questions" do #this test is not done
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)
    survey1 = Factory(:survey, :organization => org1)
    survey2 = Factory(:survey, :organization => org2)

    #puts org1.self_and_children_questions

    #assert_equal org1.self_and_children_keywords.sort{ |a, b| 1*(b <=> a) }, [keyword1, keyword2].sort{ |a, b| 1*(b <=> a) }, "Parent organization did not return correct self and children keywords"
  end

  test "unassigned_people" do

  end

  context "retrieving active keywords" do
    setup do
      @person = Factory(:person)
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)
      @keyword1 = Factory(:sms_keyword, :organization => @org1, state: 'active')
      @keyword2 = Factory(:sms_keyword, :organization => @org1, state: 'active')
      @keyword3 = Factory(:sms_keyword, :organization => @org2, state: 'active')
      @keyword4 = Factory(:sms_keyword, :organization => @org1)
      @keyword5 = Factory(:sms_keyword, :organization => @org2)
    end
    should "return the organization keywords" do
      results = @org1.active_keywords
      assert_equal(results.count, 2, "The resuts should be = 2")
      assert(results.include?(@keyword1), "This should be returned")
      assert(results.include?(@keyword2), "This should be returned")
    end
    should "not return not active keyword" do
      results = @org1.active_keywords
      assert(!results.include?(@keyword4), "This not should be returned")
    end
    should "not return active keyword of other org" do
      results = @org1.active_keywords
      assert(!results.include?(@keyword3), "This not should be returned")
    end
  end

  test "terminology enum" do
    org1 = Factory(:organization)
    org2 = Factory(:organization, :parent => org1)

    assert_equal org1.terminology_enum.sort{ |a, b| 1*(b <=> a) }, [org1.terminology, org2.terminology].uniq.sort{ |a, b| 1*(b <=> a) }, "Organization class did not return correct unique terminologies"
  end

  test "permissions" do
    org1 = Factory(:organization)
    assert_equal 3, org1.permissions.count
    assert org1.permissions.include?(Permission.admin)
    assert org1.permissions.include?(Permission.user)
    assert org1.permissions.include?(Permission.no_permissions)
  end

  test "<=>(other)" do
    org1 = Factory(:organization, :name => "Zulu")
    org2 = Factory(:organization, :name => "Yack")

    assert_equal(org1<=>(org2), 1, "Organization class returned wrong results for <=> operator")
  end

  test "validation method enum" do

  end

  test "name with keyword count" do
    org1 = Factory(:organization)
    keyword1 = Factory(:sms_keyword, :organization => org1)
    #keyword2 = Factory(:sms_keyword, :organization => org2)

    assert_equal org1.name_with_keyword_count, org1.name + " (#{SmsKeyword.count})", "Organization method name_with_keyword_count does not return right value"
  end

  test "add_leader(person)" do
    user1 = Factory(:user_with_auxs)  #user with a person object
    user2 = Factory(:user_with_auxs)
    org = Factory(:organization)

    org.add_leader(user1.person, user2.person)
    org_permission = OrganizationalPermission.last

    assert_equal org.id, org_permission.organization_id, "The last permission should have the org"
    assert_equal user1.person.id, org_permission.person_id, "The last permission should have the person"
    assert_equal user2.person.id, org_permission.added_by_id, "The last permission should have the person who adds the leader"
    assert_equal Permission::USER_ID, org_permission.permission_id, "The last permission should have the leader permission id"
  end

  test "using add_leader(person) in deleted leader" do
    user1 = Factory(:user_with_auxs)  #user with a person object
    user2 = Factory(:user_with_auxs)
    user3 = Factory(:user_with_auxs)
    org = Factory(:organization)

    # Add Leader
    org.add_leader(user1.person, user2.person)
    org_permission = OrganizationalPermission.last

    # Archive Leader
    org_permission.archive

    # Add Leader Again
    org.add_leader(user1.person, user3.person)
    org_permission = OrganizationalPermission.last

    assert_equal org.id, org_permission.organization_id, "The last permission should have the org"
    assert_equal user1.person.id, org_permission.person_id, "The last permission should have the person"
    assert_equal user3.person.id, org_permission.added_by_id, "The last permission should have the other person who adds the leader"
    assert_equal Permission::USER_ID, org_permission.permission_id, "The last permission should have the leader permission id"

  end

  test "add_contact(person)" do
    org1 = Factory(:organization)
    person1 = Factory(:person)
    org1.add_contact(person1)
    om = OrganizationalPermission.last
    assert_equal om.organization.to_s + om.person.to_s + om.permission_id.to_s, org1.to_s + person1.to_s + Permission::NO_PERMISSIONS_ID.to_s, "Organization method add_member does not correctly add contact"
  end

  test "add_admin(person)" do
    org1 = Factory(:organization)
    person1 = Factory(:person)
    org1.add_admin(person1)
    om = OrganizationalPermission.last
    assert_equal om.organization.to_s + om.person.to_s + om.permission_id.to_s, org1.to_s + person1.to_s + Permission::ADMIN_ID.to_s, "Organization method add_member does not correctly add admin"
  end

  test "add_involved(person)" do
    org1 = Factory(:organization)
    person1 = Factory(:person)
    org1.add_involved(person1)
    om = OrganizationalLabel.last
    assert_equal om.organization.to_s + om.person.to_s + om.label_id.to_s, org1.to_s + person1.to_s + Label::INVOLVED_ID.to_s, "Organization method add_member does not correctly add involved"
  end

  test "remove_contact(person)" do
    org1 = Factory(:organization)
    person1 = Factory(:person)
    org1.add_contact(person1)
    assert org1.contacts.include?(person1)
    org1.remove_contact(person1)
    assert !org1.contacts.include?(person1)
  end

  test "move_contact(person, to_org, keep_contact, current_user)" do # revise!
    person = Factory(:person_with_things)
    contact = Factory(:person)
    org1 = Factory(:organization)
    org2 = Factory(:organization)
    org1.add_contact(contact)
    org1.add_admin(person)
    FollowupComment.create(contact_id: contact.id, commenter_id: person.id, organization_id: org1.id, comment: 'test', status: 'contacted')
    org1.move_contact(contact, org2, "false", person)
    assert_equal(0, org1.contacts.length)
    assert_equal(1, org2.contacts.length)
    assert_equal(0, FollowupComment.where(contact_id: contact.id, organization_id: org1.id).count)
    assert_equal(1, FollowupComment.where(contact_id: contact.id, organization_id: org2.id).count)
  end

  test "create_admin_user" do
    org1 = Factory(:organization)
    person1 = Factory(:person)

    assert_difference "OrganizationalPermission.count", 0, "Organization method create_admin_uer created admin user despite absence of Organization person_id" do
      org1.create_admin_user
    end

    org1.person_id = person1.id
    org1.create_admin_user
    om = OrganizationalPermission.last
    assert_equal om.organization.to_s + om.person.to_s + om.permission_id.to_s, org1.to_s + person1.to_s + Permission::ADMIN_ID.to_s, "Organization method create_admin_user does not correctly add admin"
  end

  test "notify_admin_of_request" do

  end

  test "notify_new_leader(person, added_by)" do

  end

  # end method testing

  # begin deeper tests

  test "state machines test" do
    # write in this block state machine tests
  end

  context "an organization" do

    should "delete suborganizations when deleted (root organizations cannot be deleted)" do
      # it seems like there comes a problem when you are destroying an organization in which its predecessor tree is more than 2 levels deep

      org1 = Factory(:organization)
      org2 = Factory(:organization, :parent => org1)
      org3 = Factory(:organization, :parent => org2)
      org4 = Factory(:organization, :parent => org3)
      org5 = Factory(:organization, :parent => org4)

      assert_difference("Organization.count", -2, "Organizations were not deleted after parent was destroyed.") do
        org4.destroy
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

    should "have at least one parent after creation" do #this test is not yet done
      org = Factory(:organization)
      #puts org
      #puts Factory.attributes_for :organization
      #assert_not_nil org.parent
    end
  end

  test "add initial admin after creating an org" do
    person = Factory(:person)
    assert_difference "OrganizationalPermission.count", 1 do
      Factory(:organization, person_id: person.id)
    end
  end

  context "getting the admins of an org" do

  end

  context "Testing the uniqueness of an orgs children" do
    setup do
      @org = Factory(:organization)
      @child = Factory(:organization, parent: @org, name: 'org', terminology: 'org')
      @another_org = Factory(:organization)
    end

    should "not save a child org if the name is not unique" do
      another_child = Organization.new(:parent => @org, :name => 'org', :terminology => 'org')
      assert !another_child.save
      assert_not_nil another_child.errors[:name]
      assert_equal "Name is not Unique", another_child.errors[:name].first
    end

    should "save a child org if the name is uniqie" do
      another_child = Organization.new(:parent => @org, :name => 'wat', :terminology => 'wat')
      assert another_child.save
    end

    should "save a child org with the same name from another parent orgs children" do
      another_child = Organization.new(:parent => @another_org, :name => 'org', :terminology => 'org')
      assert another_child.save
    end
  end

  # end deeper tests

  context "fetching transfers for 100% Sent" do
    setup do
      @org = Factory(:organization)
      @other_org = Factory(:organization)
      @admin = Factory(:person)
      @contact1 = Factory(:person)
      @contact2 = Factory(:person)
      @contact3 = Factory(:person)
      @contact4 = Factory(:person)
      Factory(:organizational_permission, person: @admin, permission: Permission.admin, organization: @org)
      Factory(:organizational_permission, person: @contact1, permission: Permission.no_permissions, organization: @org)
      Factory(:organizational_permission, person: @contact2, permission: Permission.no_permissions, organization: @org)
      Factory(:organizational_permission, person: @contact3, permission: Permission.no_permissions, organization: @org)
      Factory(:organizational_permission, person: @contact4, permission: Permission.no_permissions, organization: @org)

      graduating_on_mission = Factory(:interaction_type, organization_id: 0, i18n: 'graduating_on_mission')
      other_interaction = Factory(:interaction_type, organization_id: 0, i18n: 'comment')
      Factory(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact1, creator: @admin, organization: @org)
      Factory(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact2, creator: @admin, organization: @org)
      Factory(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact3, creator: @admin, organization: @org)
      Factory(:interaction, interaction_type_id: other_interaction.id, receiver: @contact4, creator: @admin, organization: @org)
      Factory(:interaction, interaction_type_id: other_interaction.id, receiver: @contact3, creator: @admin, organization: @other_org)
    end
    should "return all people with label 100% Sent and not yet transferred" do
      assert @org.pending_transfer.include?(@contact1)
      assert @org.pending_transfer.include?(@contact2)
    end
    should "return all people without label 100% Sent" do
      assert_equal([@contact4], @org.available_transfer)
    end
    should "return all people with label 100% Sent and already transferred" do
      Factory(:sent_person, person: @contact3)
      assert_equal([@contact3], @org.completed_transfer)
    end
  end

  context "checking parent" do
    setup do
      @org = Organization.new(name: 'test org', ancestry: '1/2/3')
    end
    should "return true if parent_id exist" do
      assert @org.has_parent?(1)
      assert @org.has_parent?(2)
    end
    should "return true if org is root" do
      @org.update_attribute('ancestry', nil)
      assert @org.has_parent?(@org.id)
    end
    should "return false if parent_id does not exist" do
      assert !@org.has_parent?(4)
      assert !@org.has_parent?(5)
    end
  end

  context "fetching labels" do
    setup do
      @org = Factory(:organization, id: 1)
      @child_org = Factory(:organization, ancestry: '1')
      @not_child_org = Factory(:organization, ancestry: nil)
    end
    should "not return 'engaged_disciple' label if org is cru" do
      assert !@not_child_org.label_set.include?(Label.engaged_disciple), @not_child_org.label_set.collect(&:name).inspect
    end
    should "return 'engaged_disciple' label if has parent org id = 1" do
      assert @child_org.label_set.include?(Label.engaged_disciple), @child_org.label_set.collect(&:name).inspect
    end
  end

  context "getting sms_gateway" do
    setup do
      @parent1 = Factory(:organization, name: 'Parent1', ancestry: nil)
      @parent2 = Factory(:organization, name: 'Parent2', ancestry: "#{@parent1.id}")
      @parent3 = Factory(:organization, name: 'Parent3', ancestry: "#{@parent1.id}/#{@parent2.id}")
      @org = Factory(:organization, name: 'TestOrg', ancestry: "#{@parent1.id}/#{@parent2.id}/#{@parent3.id}")
    end
    should "return 'twilio' if set in settings" do
      @parent1.settings[:sms_gateway] = 'twilio'
      assert_equal 'twilio', @parent1.sms_gateway
    end
    should "return 'smseco' if set in settings" do
      @parent1.settings[:sms_gateway] = 'smseco'
      assert_equal 'smseco', @parent1.sms_gateway
    end
    should "return parent2's gateway if default is not set and parent has default" do
      @parent2.settings[:sms_gateway] = 'smseco'
      @parent2.save
      assert_equal 'smseco', @org.sms_gateway
    end
    should "return parent3's gateway if default is not set and parent has default" do
      @parent3.settings[:sms_gateway] = 'smseco'
      @parent3.save
      assert_equal 'smseco', @org.sms_gateway
    end
    should "return 'twilio' if default is not set and all ancestors do not have defaults" do
      assert_equal 'twilio', @org.sms_gateway
    end
  end
end
