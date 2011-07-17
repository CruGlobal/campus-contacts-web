require 'test_helper'

class InterestTest < ActiveSupport::TestCase

  should belong_to(:person)
  should validate_presence_of(:person_id)
  should validate_presence_of(:name)
  should validate_presence_of(:provider)
  should validate_presence_of(:interest_id)
  should validate_presence_of(:person_id)
  should validate_presence_of(:category)
  
  context "an interest" do
    setup do
      @person = Factory(:person_with_things)
    end
    
    should "be able to add an interest" do
      interest1 = @person.interests.create(provider: "facebook", name: "Books", person_id: @person.personID.to_i, interest_id: "1", category: "Things")
      assert interest1.valid?
    end
    
    should "convert to a hash well" do 
      interest = @person.interests.first
      hash = interest.to_hash
      assert_equal(hash['id'], interest.id)
      assert_equal(hash['name'], interest.name)
      assert_equal(hash['category'], interest.category)
    end
  end    
end
