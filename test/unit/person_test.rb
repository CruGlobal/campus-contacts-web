require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:firstName)
  # should validate_presence_of(:lastName)
  should have_one(:primary_phone_number)
  should have_one(:primary_email_address)
  should have_many(:phone_numbers)
  should have_many(:locations)
  should have_many(:friends)
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
      person, email, phone = Person.new_from_params({"email_address" => {"email" => "test@uscm.org"},"firstName" => "Test","lastName" => "Test","phone_number" => {"number" => ""}})
      assert_nil(phone)
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
      
      @person1 = Factory(:person, firstName: 'Leader')
      @person2 = Factory(:person, firstName: 'Contact')
      @person3 = Factory(:person, firstName: 'Admin')
      @org_role1 = Factory(:organizational_role, person: @person1, organization: @org1, role: Role.leader)
      @org_role2 = Factory(:organizational_role, person: @person2, organization: @org1, role: Role.contact)
      @org_role3 = Factory(:organizational_role, person: @person3, organization: @org1, role: Role.admin)
      
      results = Person.order_by_highest_default_role('role')
      assert_equal(results[0].firstName, 'Contact', "first person of the results should be the contact")
      assert_equal(results[1].firstName, 'Leader', "second person of the results should be the leader")
      assert_equal(results[2].firstName, 'Admin', "third person of the results should be the admin")
      
      results = Person.order_by_highest_default_role('role asc')
      assert_equal(results[0].firstName, 'Admin', "first person of the results should be the admin when order is ASC")
      assert_equal(results[1].firstName, 'Leader', "second person of the results should be the leader when order is ASC")
      assert_equal(results[2].firstName, 'Contact', "third person of the results should be the contact when order is ASC")
    end
    should "return people based on alphabetical roles" do
      @org = Factory(:organization)
      
      @person1 = Factory(:person, firstName: 'Leader')
      @person2 = Factory(:person, firstName: 'Contact')
      @person3 = Factory(:person, firstName: 'Admin')
      @org_role1 = Factory(:organizational_role, person: @person1, organization: @org1, role: Role.leader)
      @org_role2 = Factory(:organizational_role, person: @person2, organization: @org1, role: Role.contact)
      @org_role5 = Factory(:organizational_role, person: @person3, organization: @org1, role: Role.admin)
      
      @person4 = Factory(:person, firstName: 'Reader')
      @person5 = Factory(:person, firstName: 'Visitor')
      @role4 = Factory(:role, organization: @org, name: 'Reader')
      @role5 = Factory(:role, organization: @org, name: 'Visitor')
      @org_role4 = Factory(:organizational_role, person: @person4, organization: @org1, role: @role4)
      @org_role5 = Factory(:organizational_role, person: @person5, organization: @org1, role: @role5)
      
      results = Person.order_alphabetically_by_non_default_role('role')
      assert_equal(results[0].firstName, 'Reader', "first person of the results should be the reader")
      assert_equal(results[1].firstName, 'Visitor', "second person of the results should be the visitor")
      
      results = Person.order_alphabetically_by_non_default_role('role asc')
      assert_equal(results[0].firstName, 'Visitor', "first person of the results should be the visitor when order is ASC")
      assert_equal(results[1].firstName, 'Reader', "second person of the results should be the reader when order is ASC")
    end
    should "return people based on last answered survey" do
      @org = Factory(:organization)
      @survey = Factory(:survey)
      
      @person1 = Factory(:person, firstName: 'First Answer')
      @person2 = Factory(:person, firstName: 'Second Answer')
      @person3 = Factory(:person, firstName: 'Last Answer')
      @answer_sheet1 = Factory(:answer_sheet, person: @person1, survey: @survey, updated_at: "2012-07-01".to_date)
      @answer_sheet2 = Factory(:answer_sheet, person: @person1, survey: @survey, updated_at: "2012-07-02".to_date)
      @answer_sheet3 = Factory(:answer_sheet, person: @person1, survey: @survey, updated_at: "2012-07-03".to_date)
      
      results = Person.get_and_order_by_latest_answer_sheet_answered('', @org.id)
      assert_equal(results[0].firstName, 'First Answer', "first result should be the first person who answered")
      assert_equal(results[1].firstName, 'Second Answer', "second result should be the second person who answered")
      assert_equal(results[2].firstName, 'Last Answer', "third result should be the last person who answered")
      
      
    end
    should "return people assigned to an org" do
      @org1 = Factory(:organization, name: 'Org 1')
      @org2 = Factory(:organization, name: 'Org 2')
      @leader = Factory(:person, firstName: 'Leader')
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
  
  context "collect_all_child_organizations function" do
    should "return child orgs" do
      @person = Factory(:person)
      @org = Factory(:organization, id: 1)
      @org1 = Factory(:organization, id: 2, ancestry: "1")
      @org2 = Factory(:organization, id: 3, ancestry: "1")
      @org3 = Factory(:organization, id: 4, ancestry: "1/2")
      
      results = @person.collect_all_child_organizations(@org)
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
    should "should return the cellPhone from address if it exists and phone_number exists" do
      address = Address.create(cellPhone: '2222222222', fk_PersonID: @person.id, addressType: 'current')
      assert_equal(@person.phone_number, '2222222222', 'this should return the cellPhone number')
    end
    should "should return the homePhone from address if it exists and phone_number exists" do
      address = Address.create(homePhone: '3333333333', fk_PersonID: @person.id, addressType: 'current')
      assert_equal(@person.phone_number, '3333333333', 'this should return the homePhone number')
    end
    should "should return the workPhone from address if it exists and phone_number exists" do
      address = Address.create(workPhone: '4444444444', fk_PersonID: @person.id, addressType: 'current')
      assert_equal(@person.phone_number, '4444444444', 'this should return the workPhone number')
    end
    should "should return the existing if record already exists" do
      address1 = @person.phone_numbers.create(number: '4444444444', location: 'mobile')
      address2 = Address.create(workPhone: '4444444444', fk_PersonID: @person.id, addressType: 'current')
      assert_equal(@person.phone_number, '4444444444', 'this should return the workPhone number')
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
      @org_role3 = Factory(:organizational_role, person: @person3, 
        organization: @org1, role: Role.contact, deleted: 1)
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
      @person_friend1 = @person.friends.create(provider: "provider", name: "Friend1", uid: "1")
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
      @other_friend1 = @other.friends.create(provider: "provider", name: "Friend2", uid: "2")
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
      assert(@person.phone_numbers.include?(@person_phone1), "Person still have its phone number")
      assert(@person.phone_numbers.include?(@other_phone1), "Person should aquire other person's phone number data")
    end
    should "merge the locations" do
      @person.merge(@other)
      assert(@person.locations.include?(@person_location1), "Person still have its location")
      assert(@person.locations.include?(@other_location1), "Person should aquire other person's location data")
    end
    should "merge the friends" do
      @person.merge(@other)
      assert(@person.friends.include?(@person_friend1), "Person still have its friend")
      assert(@person.friends.include?(@other_friend1), "Person should aquire other person's friend data")
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
      assert_equal(@person_followup1.commenter_id, @person.personID, "Person still have its followup comment")
      assert_equal(@other_followup1.commenter_id, @person.personID, "Person should aquire other person's followup comment data")
    end
    should "merge the comments from other people" do
      @person.merge(@other)
      assert_equal(@person_comment1.contact_id, @person.personID, "Person still have its comments from other people")
      assert_equal(@other_comment1.contact_id, @person.personID, "Person should aquire other person's comments from other people data")
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
        assert_equal(@person.gender, "male")
        @person.gender = '1'
        assert_equal(@person.gender,"male")
      end
      should "be set correctly for female case" do
        @person.gender = "Female"
        assert_equal(@person.gender,"female")
        @person.gender = '0'
        assert_equal(@person.gender,"female")
      end
    end
   
    context "get friendships" do
      should "get & update friends" do
        #make sure # of friends from MiniFB = # written into DB
        @x = @person.get_friends(@authentication, TestFBResponses::FRIENDS)
        assert_equal(@x,@person.friends.all.length )
      
        #Pez's UID 
        @friend = @person.friends.find_by_uid(5108015)
        assert_equal(@friend.name, "David Pezzoli","Make sure that Pez is in the local friends DB now")
        #Todd's UID
        @friend2 = @person.friends.find_by_uid(514392571)
        @friend2.name = "Not Todd Gross"
        assert_not_equal(@friend2.name,"Todd Gross","Make sure that Todd's local DB name change went through")
      
        @friend.destroy  #delete Pez from the local DB
        friend1 = @person.friends.create(provider: "facebook", :uid =>"1", name: "Test User", person_id: @person.personID.to_i)
        friend2 = @person.friends.create(provider: "facebook", :uid =>"2", name: "Test User", person_id: @person.personID.to_i)
        x = @person.update_friends(@authentication, TestFBResponses::FRIENDS)
        assert_equal(3, x, "Make sure that three changes took place... 2 deletions and 1 addition")
      
        friend1 = @person.friends.find_by_uid("1")
        friend2 = @person.friends.find_by_uid("2")
        assert_nil(friend1, "Make sure that test friend 1 was deleted")
        assert_nil(friend2, "Make sure that test friend 2 was deleted")
        
        @friend = @person.friends.find_by_uid(5108015)
        assert_equal(@friend.name,"David Pezzoli", "Make sure that Pez was readded")
      
        @friend2.reload
        assert_equal(@friend2.name, "Todd Gross", "Make sure that Todd's name was updated")
      end

      should "insert friendship to redis database" do
        @person.get_friends(@authentication, TestFBResponses::FRIENDS)
        assert_equal(Friend.followers(@person).length, @person.friends.all.length)
 
        @person.update_friends(@authentication, TestFBResponses::FRIENDS)
        assert_equal(Friend.followers(@person).length, @person.friends.all.length)
      end
    end
    
    should "not create a duplicate email when adding an email they already have" do
      primary_email = @person.email_addresses.create(email: 'test1@example.com')
      assert primary_email.primary?
      secondary_email = @person.email_addresses.create(email: 'test2@example.com')
      @person.email = 'test2@example.com'
      @person.reload
      assert_equal(secondary_email, @person.primary_email_address)
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
      assert(['male', 'female'].include?(person.gender))
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
    Factory(:organizational_role, organization: org, person: user.person, role: Role.leader)
    wat = nil
    assert user.person.leader_in?(org)
    assert_equal false, user.person.leader_in?(wat)
  end

  should "should find people by name or meail given wildcard strings" do
    org = Factory(:organization)
    user = Factory(:user_with_auxs)
    Factory(:organizational_role, organization: org, person: user.person, role: Role.leader)
    person1 = Factory(:person, firstName: "Neil Marion", lastName: "dela Cruz", email: "ndc@email.com")
    Factory(:organizational_role, organization: org, person: person1, role: Role.leader)
    person2 = Factory(:person, firstName: "Johnny", lastName: "English", email: "english@email.com")
    Factory(:organizational_role, organization: org, person: person2, role: Role.contact)
    person3 = Factory(:person, firstName: "Johnny", lastName: "Bravo", email: "bravo@email.com")
    Factory(:organizational_role, organization: org, person: person3, role: Role.contact)

    a = org.people.search_by_name_or_email("neil marion", org.id)
    assert_equal a.count, 1 # should be able to find a leader as well

    a = org.people.search_by_name_or_email("ndc", org.id)
    assert_equal a.count, 1 #should be able to find by an email address wildcard

    a = org.people.search_by_name_or_email("hnny", org.id) # as in Johnny
    assert_equal a.count, 2 #should be able to find contacts
  end
end
