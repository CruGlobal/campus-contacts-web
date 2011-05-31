require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should belong_to(:user)
  should validate_presence_of(:firstName)
  should validate_presence_of(:lastName)
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
  
  context "a person" do
    setup do
      @person = Factory(:person)
      @authentication = Factory(:authentication)
    end
    should "output the person's correct full name" do 
      assert_equal(@person.to_s, "John Doe")
      @person.preferredName = "Buford"
      assert_equal(@person.to_s, "Buford Doe")
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
      friend1 = @person.friends.create(:provider => "facebook", :uid =>"1", :name => "Test User", :person_id => @person.personID.to_i)
      friend2 = @person.friends.create(:provider => "facebook", :uid =>"2", :name => "Test User", :person_id => @person.personID.to_i)
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
    
    should "get & update interests" do
      x = @person.get_interests(@authentication)
      assert(x > 0, "Make sure we now have at least one interest")
      assert(@person.interests.first.name.is_a? String)
    end
    
    should "get & update location" do
      @response = MiniFB.get(@authentication.token, @authentication.uid)
      x = @person.get_location(@authentication, @response)
      assert(@person.locations.first.name.is_a? String)
      
      number_of_locations1 = @person.locations.all.length
      x = @person.get_location(@authentication)
      number_of_locations2 = @person.locations.all.length
      assert_equal(number_of_locations1, number_of_locations2, "Ensure no duplicate locations")
    end
    
    should "get & update education history" do
      real_response = MiniFB.get(@authentication.token, @authentication.uid)
      array_of_responses = [real_response, TestFBResponses::FULL, TestFBResponses::NO_CONCENTRATION, TestFBResponses::NO_YEAR, TestFBResponses::WITH_DEGREE, TestFBResponses::NO_EDUCATION]
    
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
      data_hash = Hashie::Mash.new({:first_name => "Matt", :last_name => "Webb", :email => "mattrw89@gmail.com"})
      person = Person.create_from_facebook(data_hash,@authentication)
      assert(person.locations.first.name.is_a? String)
      assert(person.friends.first.name.is_a? String)
      assert(person.interests.first.name.is_a? String)
      assert(person.education_histories.first.school_name.is_a? String)
      assert(person.gender == ('male' || 'female'))
      assert_equal(person.email.email, "mattrw89@gmail.com", "See if person has correct email address")
    end    
  end
end
