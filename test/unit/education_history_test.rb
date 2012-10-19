require 'test_helper'

class EducationHistoryTest < ActiveSupport::TestCase
  should belong_to(:person)
  should validate_presence_of(:person_id)
  should validate_presence_of(:school_id)
  should validate_presence_of(:school_name)
  should validate_presence_of(:provider)
  should validate_presence_of(:school_type)
  
  context "a school" do
    setup do
      @person = Factory(:person_with_things)
    end
    
    should "be able to add a school" do
      school1 = @person.education_histories.create(school_type: "High School", provider: "facebook", school_name: "Test School", person_id: @person.id.to_i, school_id: "1")
      assert school1.valid?
    end
    
    should "convert to a hash well" do 
      eh_count = @person.education_histories.count
      assert_equal(eh_count, 3)
      @eh = @person.education_histories.where("school_id = ?","2").first
      hash = @eh.to_hash
      assert_equal(hash['school']['id'], "2")
      assert_equal(hash['school']['name'], "Test University 2")
      assert_equal(hash['type'], "College")
      assert_equal(hash['year']['id'],"4")
      assert_equal(hash['year']['name'],"2014")
      assert_equal(hash['degree']['id'],"1")
      assert_equal(hash['degree']['name'],"Masters")
      assert_equal(hash['concentration'][0]['id'], "13")
      assert_equal(hash['concentration'][0]['name'], "Test Major 4")
      assert_equal(hash['concentration'][1]['id'], "43")
      assert_equal(hash['concentration'][1]['name'], "Test Major 5")
      assert_equal(hash['concentration'][2]['id'], "86")
      assert_equal(hash['concentration'][2]['name'], "Test Major 6")
    end
  end
end