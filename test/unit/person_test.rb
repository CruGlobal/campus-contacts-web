require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:firstName)
  # should validate_presence_of(:lastName)
  should have_one(:primary_organization)
  should have_one(:primary_organization_membership)
  should have_one(:primary_phone_number)
  should have_one(:primary_email_address)
  should have_many(:phone_numbers)
  should have_many(:locations)
  should have_many(:friends)
  should have_many(:interests)
  should have_many(:education_histories)
  should have_many(:email_addresses)
  should have_many(:organizations)
  should have_many(:organization_memberships)
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
      assert(!orgs.include?(@org3), "this should not be included since its parent does not show sub orgs.")
      assert(orgs.include?(@org4), "this should be included since its parent belongs to Person and shows sub orgs.")
      assert_equal(orgs.count, 3, "duplicate entries are present.")
    end
    
    should "show multiple-generations of children as long as show_sub_orgs is true" do
      @org1 = Factory(:organization, person_id: @person.id, id: 1)
      @org2 = Factory(:organization, person_id: @another_person.id, id: 2, ancestry: "1")
      @org3 = Factory(:organization, person_id: @another_person.id, id: 3, ancestry: "1/2")
      @org4 = Factory(:organization, person_id: @another_person.id, id: 4, ancestry: "1/2/3")
      orgs = @person.orgs_with_children
      assert(orgs.include?(@org1), "root should be included, if Person is leader.")
      assert(orgs.include?(@org2), "this should be included because parent shows sub orgs")
      assert(orgs.include?(@org3), "this should be included because parent shows sub orgs")
      assert(orgs.include?(@org4), "this should be included because parent shows sub orgs")
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
      (1..3).each do |index| 
        default_role = Role.create!(organization_id: 0, name: "default_role_#{index}", i18n: "default_role_#{index}") 
        role = Role.create!(organization_id: 1, name: "role_#{index}", i18n: "role_#{index}") 
        @person.organizational_roles.create!(organization_id: 1, role_id: default_role.id)
        @person.organizational_roles.create!(organization_id: 1, role_id: role.id)
      end
  
      assert_equal(@person.assigned_organizational_roles(1).count, 6) 
    end
    
    should 'create and return vcard information of a person' do  
      vcard = @person.vcard
          
      assert_not_nil(vcard.name)
      assert_equal(Vpim::Vcard, vcard.class)      
    end
    
  end
end
