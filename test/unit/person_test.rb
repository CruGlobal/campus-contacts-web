require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:first_name)
  # should validate_presence_of(:last_name)
  should have_one(:primary_phone_number)
  should have_one(:primary_email_address)
  should have_many(:phone_numbers)
  should have_many(:locations)
  should have_many(:interests)
  should have_many(:education_histories)
  should have_many(:email_addresses)
  should have_many(:organizations)
  should have_many(:answer_sheets)
  should have_many(:contact_assignments)
  should have_many(:assigned_tos)
  should have_many(:assigned_contacts)

  context "create a person from params" do
    should "not fail if there's no phone number when adding a person who already exists" do
      Factory(:user_with_auxs, email: 'test@uscm.org')
      person = Person.new_from_params({"email_address" => {"email" => "test@uscm.org"},"first_name" => "Test","last_name" => "Test","phone_number" => {"number" => ""}})
      assert_nil(person.phone_numbers.first)
    end
  end

  context "get people functions" do
    should "return people that are updated within the specified date_rage" do
      @person = Factory(:person, date_attributes_updated: "2012-07-25".to_date)

      results = Person.find_by_person_updated_by_daterange("2012-07-01".to_date, "2012-07-31".to_date)
      assert(results.include?(@person), "results should include the updated person within the range")

      results = Person.find_by_person_updated_by_daterange("2012-07-20".to_date, "2012-07-01".to_date)
      assert(!results.include?(@person), "results should not include the updated person after the given range")

      results = Person.find_by_person_updated_by_daterange("2012-07-28".to_date, "2012-07-31".to_date)
      assert(!results.include?(@person), "results should not include the updated person before the given range")
    end
    should "return people based on highest default roles" do
      @org = Factory(:organization)

      @person1 = Factory(:person, first_name: 'Leader')
      @person2 = Factory(:person, first_name: 'Contact')
      @person3 = Factory(:person, first_name: 'Admin')
      @org_role1 = Factory(:organizational_role, person: @person1, organization: @org1, role: Role.missionhub_user)
      @org_role2 = Factory(:organizational_role, person: @person2, organization: @org1, role: Role.contact)
      @org_role3 = Factory(:organizational_role, person: @person3, organization: @org1, role: Role.admin)

      results = Person.order_by_highest_default_role('role')
      assert_equal(results[0].first_name, 'Contact', "first person of the results should be the contact")
      assert_equal(results[1].first_name, 'Leader', "second person of the results should be the leader")
      assert_equal(results[2].first_name, 'Admin', "third person of the results should be the admin")

      results = Person.order_by_highest_default_role('role asc')
      assert_equal(results[0].first_name, 'Admin', "first person of the results should be the admin when order is ASC")
      assert_equal(results[1].first_name, 'Leader', "second person of the results should be the leader when order is ASC")
      assert_equal(results[2].first_name, 'Contact', "third person of the results should be the contact when order is ASC")
    end
    should "return people based on alphabetical roles" do
      @org = Factory(:organization)

      @person1 = Factory(:person, first_name: 'Leader')
      @person2 = Factory(:person, first_name: 'Contact')
      @person3 = Factory(:person, first_name: 'Admin')
      @org_role1 = Factory(:organizational_role, person: @person1, organization: @org1, role: Role.missionhub_user)
      @org_role2 = Factory(:organizational_role, person: @person2, organization: @org1, role: Role.contact)
      @org_role5 = Factory(:organizational_role, person: @person3, organization: @org1, role: Role.admin)

      @person4 = Factory(:person, first_name: 'Reader')
      @person5 = Factory(:person, first_name: 'Visitor')
      @role4 = Factory(:role, organization: @org, name: 'Reader')
      @role5 = Factory(:role, organization: @org, name: 'Visitor')
      @org_role4 = Factory(:organizational_role, person: @person4, organization: @org1, role: @role4)
      @org_role5 = Factory(:organizational_role, person: @person5, organization: @org1, role: @role5)

      results = Person.order_alphabetically_by_non_default_role('role')
      assert_equal(results[0].first_name, 'Reader', "first person of the results should be the reader")
      assert_equal(results[1].first_name, 'Visitor', "second person of the results should be the visitor")

      results = Person.order_alphabetically_by_non_default_role('role asc')
      assert_equal(results[0].first_name, 'Visitor', "first person of the results should be the visitor when order is ASC")
      assert_equal(results[1].first_name, 'Reader', "second person of the results should be the reader when order is ASC")
    end


    context "person's survey functions" do
      setup do
        @org = Factory(:organization)

        @survey1 = Factory(:survey, organization: @org)
        @survey2 = Factory(:survey, organization: @org)
        @survey3 = Factory(:survey, organization: @org)
        @survey4 = Factory(:survey, organization: @org)

        @person1 = Factory(:person, first_name: 'First Person')
        @person2 = Factory(:person, first_name: 'Second Person')

        @answer_sheet1 = Factory(:answer_sheet, person: @person1, survey: @survey1, updated_at: "2012-07-02".to_date)
        @answer_sheet2 = Factory(:answer_sheet, person: @person1, survey: @survey2, updated_at: "2012-07-01".to_date)
        @answer_sheet3 = Factory(:answer_sheet, person: @person1, survey: @survey3, updated_at: "2012-07-03".to_date)
        @answer_sheet4 = Factory(:answer_sheet, person: @person2, survey: @survey4, updated_at: "2012-07-03".to_date)
      end

      should "return all answer_sheets of a person in completed_answer_sheets function" do
        results = @person1.completed_answer_sheets(@org)
        assert_equal(results[0], @answer_sheet3, "first result should be the 3rd answer sheet")
        assert_equal(results[1], @answer_sheet1, "second result should be the 1st answer sheet")
        assert_equal(results[2], @answer_sheet2, "third result should be the 2nd answer sheet")
      end

      should "not return an answer_sheets which is not answered by the person in completed_answer_sheets function" do
        results = @person1.completed_answer_sheets(@org)
        assert !results.include?(@answer_sheet4)
      end

      should "return the latest answer_sheet of a person in latest_answer_sheet function" do
        results = @person1.latest_answer_sheet(@org)
        assert_equal(results, @answer_sheet3, "should be the 3rd answer sheet")
      end

      should "not return the latest answer_sheet of other person in latest_answer_sheet function" do
        result = @person1.latest_answer_sheet(@org)
        assert_not_equal result, @answer_sheet4
      end
    end

    should "return people based on last answered survey" do
      @org = Factory(:organization)
      @survey = Factory(:survey)

      @person1 = Factory(:person, first_name: 'First Answer')
      @person2 = Factory(:person, first_name: 'Second Answer')
      @person3 = Factory(:person, first_name: 'Last Answer')
      Factory(:organizational_role, person: @person1, organization: @org, role: Role.contact)
      Factory(:organizational_role, person: @person2, organization: @org, role: Role.contact)
      Factory(:organizational_role, person: @person3, organization: @org, role: Role.contact)
      @as1 = Factory(:answer_sheet, person: @person1, survey: @survey, updated_at: "2013-07-01".to_date)
      @as2 = Factory(:answer_sheet, person: @person2, survey: @survey, updated_at: "2013-07-02".to_date)
      @as3 = Factory(:answer_sheet, person: @person3, survey: @survey, updated_at: "2013-07-03".to_date)
      results = Person.get_and_order_by_latest_answer_sheet_answered('ASC', @org.id)
      # assert_equal(@person1.first_name, results[0].first_name, "first result should be the first person who answered")
      # assert_equal(@person2.first_name, results[1].first_name, "second result should be the second person who answered")
      # assert_equal(@person3.first_name, results[2].first_name, "third result should be the last person who answered")
    end

    should "return people assigned to an org" do
      @org1 = Factory(:organization, name: 'Org 1')
      @org2 = Factory(:organization, name: 'Org 2')
      @leader = Factory(:person, first_name: 'Leader')
      @person = Factory(:person)

      @assignment1 = Factory(:contact_assignment, organization: @org1, person: @person, assigned_to: @leader)
      @assignment2 = Factory(:contact_assignment, organization: @org2, person: @person, assigned_to: @leader)

      results = @person.assigned_tos_by_org(@org1)
      assert(results.include?(@assignment1), "results should include contact_assignment for org 1")

      results = @person.assigned_tos_by_org(@org2)
      assert(results.include?(@assignment2), "results should include contact_assignment for org 2")
    end
  end

  context "person organizations and sub-organizations" do

    setup do
      @person = Factory(:person)
      @another_person = Factory(:person)
    end

    should "not show children if show_sub_orgs is false" do
      @org1 = Factory(:organization, person_id: @person.id, id: 1)
      @org2 = Factory(:organization, show_sub_orgs: false, person_id: @person.id, id: 2, ancestry: "1")
      @org3 = Factory(:organization, person_id: @person.id, id: 3, ancestry: "1/2")
      @org4 = Factory(:organization, person_id: @another_person.id, id: 4, ancestry: "1/2/3")
      orgs = @person.orgs_with_children
      assert(orgs.include?(@org1), "root should be included, if Person is leader.")
      assert(orgs.include?(@org2), "this should be included because parent shows sub orgs")
      assert(orgs.include?(@org3), "this should not be included because parent doesnt show sub orgs")
      assert(!orgs.include?(@org4), "this should not be included")
      assert_equal(orgs.count, 3, "duplicate entries are present.")

      other_orgs = @another_person.orgs_with_children
      assert(!other_orgs.include?(@org1), "this should not be included")
      assert(!other_orgs.include?(@org2), "this should not be included")
      assert(!other_orgs.include?(@org3), "this should not be included")
      assert(other_orgs.include?(@org4), "this should be included because other person has role")
    end

    should "show multiple-generations of children as long as show_sub_orgs is true" do
      @org1 = Factory(:organization, person_id: @person.id, id: 1)
      @org2 = Factory(:organization, person_id: @another_person.id, id: 2, ancestry: "1")
      @org3 = Factory(:organization, person_id: @another_person.id, id: 3, ancestry: "1/2")
      @org4 = Factory(:organization, person_id: @another_person.id, id: 4, ancestry: "1/2/3")
      orgs = @person.orgs_with_children
      assert(orgs.include?(@org1), "root should be included, if Person is leader.")
      assert(orgs.include?(@org2), "this should be included because parent shows sub orgs")
      assert(!orgs.include?(@org3), "this should not be included since another person owns this org")
      assert(!orgs.include?(@org4), "this should not be included since another person owns this org")

      other_orgs = @another_person.orgs_with_children
      assert(!other_orgs.include?(@org1), "this should not be included")
      assert(other_orgs.include?(@org2), "this should not be included")
      assert(other_orgs.include?(@org3), "this should be included")
      assert(other_orgs.include?(@org4), "this should be included")
    end

    should "show multiple generations" do
      @org1 = Factory(:organization, person_id: @another_person.id, id: 1)
      @org2 = Factory(:organization, person_id: @person.id, id: 2, ancestry: "1")
      @org3 = Factory(:organization, person_id: @another_person.id, id: 3, ancestry: "1/2")
      @org4 = Factory(:organization, person_id: @another_person.id, id: 4, ancestry: "1/2/3")
      orgs = @person.orgs_with_children
      assert(!orgs.include?(@org1), "not included since Person is not leader")
      assert(orgs.include?(@org2), "this should be included because parent shows sub orgs")
      assert(orgs.include?(@org3), "this should be included because parent shows sub orgs")
      assert(!orgs.include?(@org4), "this should not be included since another person owns this org")

      other_orgs = @another_person.orgs_with_children
      assert(other_orgs.include?(@org1), "this should be included")
      assert(other_orgs.include?(@org2), "this should be included since parent shows sub orgs")
      assert(other_orgs.include?(@org3), "this should be included")
      assert(other_orgs.include?(@org4), "this should be included")
    end

  end

  context "all_organization_and_children function" do
    should "return child orgs" do
      @person = Factory(:person)
      @org = Factory(:organization, id: 1)
      @org1 = Factory(:organization, id: 2, ancestry: "1")
      @org2 = Factory(:organization, id: 3, ancestry: "1")
      @org3 = Factory(:organization, id: 4, ancestry: "1/2")
      @org.add_admin(@person)

      results = @person.all_organization_and_children
      assert(results.include?(@org1), "Organization1 should be included")
      assert(results.include?(@org2), "Organization2 should be included")
      assert(results.include?(@org3), "Organization3 should be included")
    end
  end

  context "getting the phone number" do
    setup do
      @person = Factory(:person)
    end
    should "should return the phone_number if it exists" do
      mobile_number = @person.phone_numbers.create(number: '1111111111', location: 'mobile')
      assert_equal(@person.phone_number, '1111111111', 'this should return the mobile number')
    end
  end

  context "getting archived people" do
    setup do
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)

      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
      @person4 = Factory(:person)
      @org_role1 = Factory(:organizational_role, person: @person1,
                           organization: @org1, role: Role.contact, archive_date: Date.today)
      @org_role2 = Factory(:organizational_role, person: @person2,
                           organization: @org1, role: Role.contact)
      @org_role4 = Factory(:organizational_role, person: @person4,
                           organization: @org2, role: Role.contact)
    end
    should "return all included person that has active role" do
      results = @org1.people.archived_included
      assert_equal(results.count, 2)
    end
    should "not return a deleted person" do
      results = @org1.people.archived_included
      assert(!results.include?(@person3), "Person 3 should not be included")
    end
    should "not return person from other org" do
      results = @org1.people.archived_included
      assert(!results.include?(@person4), "Person 3 should not be included")
    end
    should "return all not included person that has active role" do
      results = @org1.people.archived_not_included
      assert_equal(results.count, 1)
    end
    should "not return a person with archive_date" do
      results = @org1.people.archived_not_included
      assert(!results.include?(@person1), "Person 1 should not be included")
    end
  end

  context "removing contact assignment" do
    setup do
      @leader1 = Factory(:person)
      @leader2 = Factory(:person)
      @leader3 = Factory(:person)
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)

      @assignment1 = Factory(:contact_assignment, organization: @org1, person: @person1, assigned_to: @leader1)
      @assignment2 = Factory(:contact_assignment, organization: @org1, person: @person2, assigned_to: @leader1)
      @assignment3 = Factory(:contact_assignment, organization: @org1, person: @person3, assigned_to: @leader2)
      @assignment4 = Factory(:contact_assignment, organization: @org2, person: @person1, assigned_to: @leader1)
    end
    should "delete assigned contacts" do
      @leader1.remove_assigned_contacts(@org1)
      assert(!ContactAssignment.all.include?(@assignment1), "This assignment should be deleted")
      assert(!ContactAssignment.all.include?(@assignment2), "This assignment should be deleted")
    end
    should "not delete assigned contacts to other leader" do
      @leader1.remove_assigned_contacts(@org1)
      assert(ContactAssignment.all.include?(@assignment3), "This assignment should not be deleted")
    end
    should "not delete assigned contacts from other org" do
      @leader1.remove_assigned_contacts(@org1)
      assert(ContactAssignment.all.include?(@assignment4), "This assignment should not be deleted")
    end
    should "not delete any assignments if no one is assigned to a leader" do
      @leader3.remove_assigned_contacts(@org1)
      initial_assignment_count = ContactAssignment.count
      assert_equal(initial_assignment_count, ContactAssignment.count)
    end
  end

  context "merging a contact" do
    setup do
      @contact = Factory(:person)
      @org = Factory(:organization)

      @person = Factory(:person)
      @person_phone1 = @person.phone_numbers.create(number: '1111111', location: 'mobile')
      @person_location1 = @person.locations.create(provider: "provider", name: "Location1", location_id: "1")
      @person_friend1 = Friend.new("1", 'Friend1', @person, 'provider')
      @person_interest1 = @person.interests.create(provider: "provider", name: "Interest1",
                                                   interest_id: "1", category: "category")
      @person_education1 = @person.education_histories.create(school_type: "HighSchool", provider: "provider",
                                                              school_name: "SchoolName1", school_id: "1")
      @person_followup1 = @person.followup_comments.create(contact_id: @contact.id, comment: "Comment1",
                                                           organization_id: @org.id)
      @person_comment1 = @person.comments_on_me.create(commenter_id: @contact.id, comment: "Comment1",
                                                       organization_id: @org.id)
      @person_email1 = @person.email_addresses.create(email: 'person@email.com')

      @other = Factory(:person)
      @other_phone1 = @other.phone_numbers.create(number: '3333333', location: 'mobile')
      @other_location1 = @other.locations.create(provider: "provider", name: "Location2", location_id: "2")
      @other_friend1 = Friend.new("2", 'Friend2', @other, 'provider')
      @other_interest1 = @other.interests.create(provider: "provider", name: "Interest2",
                                                 interest_id: "2", category: "category")
      @other_education1 = @other.education_histories.create(school_type: "HighSchool", provider: "provider",
                                                            school_name: "SchoolName2", school_id: "2")
      @other_followup1 = @other.followup_comments.create(contact_id: @contact.id, comment: "Comment2",
                                                         organization_id: @org.id)
      @other_comment1 = @other.comments_on_me.create(commenter_id: @contact.id, comment: "Comment2",
                                                     organization_id: @org.id)
      @other_email1 = @other.email_addresses.create(email: 'other@email.com')
    end
    should "merge the phone numbers" do
      @person.merge(@other)
      assert(@person.phone_numbers.include?(@person_phone1), "Person should still have its phone number")
      assert(@person.phone_numbers.include?(@other_phone1), "Person should aquire other person's phone number data")
    end
    should "merge the locations" do
      @person.merge(@other)
      assert(@person.locations.include?(@person_location1), "Person should still have its location")
      assert(@person.locations.include?(@other_location1), "Person should aquire other person's location data")
    end
    should "merge the friends" do
      @person.merge(@other)
      assert(Friend.followers(@person).include?(@person_friend1.uid), "Person should still have its friend")
      assert(Friend.followers(@person).include?(@other_friend1.uid), "Person should aquire other person's friend data")
    end
    should "merge the interests" do
      @person.merge(@other)
      assert(@person.interests.include?(@person_interest1), "Person still have its interest")
      assert(@person.interests.include?(@other_interest1), "Person should aquire other person's interest data")
    end
    should "merge the educational history" do
      @person.merge(@other)
      assert(@person.education_histories.include?(@person_education1), "Person still have its education history")
      assert(@person.education_histories.include?(@other_education1), "Person should aquire other person's education history data")
    end
    should "merge the followup comments" do
      @person.merge(@other)
      assert_equal(@person_followup1.commenter_id, @person.id, "Person still have its followup comment")
      assert_equal(@other_followup1.commenter_id, @person.id, "Person should aquire other person's followup comment data")
    end
    should "merge the comments from other people" do
      @person.merge(@other)
      assert_equal(@person_comment1.contact_id, @person.id, "Person still have its comments from other people")
      assert_equal(@other_comment1.contact_id, @person.id, "Person should aquire other person's comments from other people data")
    end
    should "merge the email address" do
      @person.merge(@other)
      assert(@person.email_addresses.include?(@person_email1), "Person still have its email address")
      assert(@person.email_addresses.include?(@other_email1), "Person should aquire other person's email address data")
    end
  end

  context "a person" do
    setup do
      @person = Factory(:person)
      @authentication = Factory(:authentication)
    end
    should "output the person's correct full name" do
      assert_equal(@person.to_s, "John Doe")
    end

    context "has a gender which" do
      should "be set correctly for male case" do
        @person.gender = "Male"
        assert_equal(@person.gender, "Male")
        @person.gender = '1'
        assert_equal(@person.gender,"Male")
      end
      should "be set correctly for female case" do
        @person.gender = "Female"
        assert_equal(@person.gender,"Female")
        @person.gender = '0'
        assert_equal(@person.gender,"Female")
      end
    end

    context "get friendships" do
      should "get friends" do
        #make sure # of friends from MiniFB = # written into DB
        existing_friends = @person.friend_uids
        @x = @person.get_friends(@authentication, TestFBResponses::FRIENDS)
        assert_equal(@x, @person.friend_uids.length + existing_friends.length )
      end

      should "update friends" do
        friend1 = Friend.new('1', 'Test User', @person)
        x = @person.update_friends(@authentication, TestFBResponses::FRIENDS)

        # Make sure new friends get deleted
        assert(!@person.friend_uids.include?(friend1.uid))

      end

    end

    should "not create a duplicate email when adding an email they already have" do
      primary_email = @person.email_addresses.create(email: 'test1@example.com')
      assert primary_email.primary?
      secondary_email = @person.email_addresses.create(email: 'test2@example.com')
      assert_no_difference "EmailAddress.count" do
        @person.email = 'test2@example.com'
        @person.save
      end
    end

    should "get & update interests" do
      x = @person.get_interests(@authentication, TestFBResponses::INTERESTS)
      assert(x > 0, "Make sure we now have at least one interest")
      assert(@person.interests.first.name.is_a? String)
    end

    should "get & update location" do
      #@response = MiniFB.get(@authentication.token, @authentication.uid)
      x = @person.get_location(@authentication, TestFBResponses::FULL)
      assert(@person.locations.first.name.is_a? String)

      number_of_locations1 = @person.locations.all.length
      x = @person.get_location(@authentication, TestFBResponses::FULL)
      number_of_locations2 = @person.locations.all.length
      assert_equal(number_of_locations1, number_of_locations2, "Ensure no duplicate locations")
    end

    should "get & update education history" do
      #real_response = MiniFB.get(@authentication.token, @authentication.uid)
      array_of_responses = [ TestFBResponses::FULL, TestFBResponses::NO_CONCENTRATION, TestFBResponses::NO_YEAR, TestFBResponses::WITH_DEGREE, TestFBResponses::NO_EDUCATION]

      array_of_responses.each do |response|
        @response = response
        num_schools_on_fb = @response.try(:education).nil? ? 0 : @response.education.length
        x = @person.get_education_history(@authentication, @response)
        number_of_schools1 = @person.education_histories.all.length
        #raise @response.education.first.school.name
        name1 = @response.try(:education).nil? ? "" : @response.education.first.school.name
        name2 = @person.education_histories.all.length > 0 ? @person.education_histories.first.school_name : ""
        assert_equal(name1, name2, "Assure name is properly written into DB")

        #do it again and ensure that no duplicate school entries are created
        x = @person.get_education_history(@authentication, @response)
        number_of_schools2 = @person.education_histories.all.length
        assert_equal(number_of_schools1, num_schools_on_fb, "Check number of schools on FB is equal to our DB after first method call")
        assert_equal(number_of_schools2, num_schools_on_fb, "Check number of schools on FB is equal to our DB after second method call")

        @person.education_histories.each do |z|
          z.destroy
        end
      end
    end

    should "create from facebook and return a person" do
      data_hash = Hashie::Mash.new({first_name: "Matt", last_name: "Webb", email: "mattrw89@gmail.com"})
      person = Person.create_from_facebook(data_hash,@authentication, TestFBResponses::FULL)
      assert(person.locations.first.name.is_a? String)
      assert(person.education_histories.first.school_name.is_a? String)
      assert(['Male', 'Female'].include?(person.gender))
      assert_equal(person.email, "mattrw89@gmail.com", "See if person has correct email address")
    end

    should "get organizational roles" do
      org = Factory(:organization)
      roles = Array.new
      (1..3).each do |index|
        roles << Role.create!(organization_id: org.id, name: "role_#{index}", i18n: "role_#{index}")
      end

      roles.each do |role|
        @person.organizational_roles.create!(organization_id: org.id, role_id: role.id)
      end

      assert_equal(@person.assigned_organizational_roles([org.id]).count, roles.count)
    end

    should 'create and return vcard information of a person' do
      vcard = @person.vcard

      assert_not_nil(vcard.name)
      assert_equal(Vpim::Vcard, vcard.class)
    end

  end

  should "check if person is leader in an org" do
    user = Factory(:user_with_auxs)
    org = Factory(:organization)
    Factory(:organizational_role, organization: org, person: user.person, role: Role.missionhub_user)
    wat = nil
    assert user.person.missionhub_user_in?(org)
    assert_equal false, user.person.missionhub_user_in?(wat)
  end

  should "should find people by name or meail given wildcard strings" do
    org = Factory(:organization)
    user = Factory(:user_with_auxs)
    Factory(:organizational_role, organization: org, person: user.person, role: Role.missionhub_user)
    person1 = Factory(:person, first_name: "Neil Marion", last_name: "dela Cruz", email: "ndc@email.com")
    Factory(:organizational_role, organization: org, person: person1, role: Role.missionhub_user)
    person2 = Factory(:person, first_name: "Johnny", last_name: "English", email: "english@email.com")
    Factory(:organizational_role, organization: org, person: person2, role: Role.contact)
    person3 = Factory(:person, first_name: "Johnny", last_name: "Bravo", email: "bravo@email.com")
    Factory(:organizational_role, organization: org, person: person3, role: Role.contact)

    a = org.people.search_by_name_or_email("neil marion", org.id)
    assert_equal a.count, 1 # should be able to find a leader as well

    a = org.people.search_by_name_or_email("ndc", org.id)
    assert_equal a.count, 1 #should be able to find by an email address wildcard

    a = org.people.search_by_name_or_email("hnny", org.id) # as in Johnny
    assert_equal a.count, 2 #should be able to find contacts
  end

  context "merging 2 same admin persons in an org with an implied admin should" do
    should "not loose its admin abilities in that org" do
      user = Factory(:user_with_auxs)
      child_org = Factory(:organization, :name => "neilmarion", :parent => user.person.organizations.first, :show_sub_orgs => true)
      Factory(:organizational_role, organization: child_org, person: user.person, role: Role.contact)
      Factory(:organizational_role, organization: child_org, person: user.person, role: Role.missionhub_user)
      assert_equal user.person.admin_of_org_ids.sort, [user.person.organizations.first.id, child_org.id].sort
    end
  end

  should 'find an existing person based on name and phone number' do
    person = Factory(:person)
    person.phone_number = '555-555-5555'
    person.save!
    assert_equal(person, Person.find_existing_person_by_name_and_phone({first_name: person.first_name,
                                                                last_name: person.last_name,
                                                                number: '555-555-5555'}))
  end

  should 'find an existing person based on fb_uid' do
    person = Factory(:person, fb_uid: '5')

    assert_equal(person, Person.find_existing_person(Person.new(fb_uid: '5')))
  end
end
