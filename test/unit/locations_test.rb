require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  should belong_to(:person)
  should validate_presence_of(:person_id)
  should validate_presence_of(:name)
  should validate_presence_of(:provider)
  should validate_presence_of(:location_id)
  
  context "a location" do
    setup do
      @person = Factory(:person_with_things)
    end
    should "be able to add a location" do
      location1 = @person.locations.create(provider: "facebook", name: "Books", person_id: @person.personID.to_i, location_id: "1")
      assert location1.valid?
    end
    should "convert to a hash well" do 
      location = @person.locations.first
      hash = location.to_hash
      assert_equal(hash['name'], "Orlando, FL")
      assert_equal(hash['id'], "1")
      assert_equal(hash['provider'], "facebook")
    end
  end
end
