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
    end
    should "output most correct full name" do 
      assert_equal(@person.to_s, "John Doe")
      @person.preferredName = "Buford"
      assert_equal(@person.to_s, "Buford Doe")
    end
  end
end
