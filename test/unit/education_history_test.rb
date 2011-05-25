require 'test_helper'

class EducationHistoryTest < ActiveSupport::TestCase
  should belong_to(:person)
  should validate_presence_of(:person_id)
  should validate_presence_of(:school_id)
  should validate_presence_of(:school_name)
  should validate_presence_of(:provider)
  
  context "a school" do
    setup do
      @person = Factory(:person)
    end
    should "be able to add a school" do
      school1 = @person.education_histories.create(:provider => "facebook", :school_name => "Test School", :person_id => @person.personID.to_i, :school_id => "1")
      assert school1.valid?
    end
  end
end
