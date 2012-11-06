require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  should belong_to(:person)
  should validate_presence_of(:address_type)
  
  context "htmlify address" do
    setup do
      @person = Factory(:person)
    end
    
    should "output correct text" do
      a = Address.new(:address1 => "Cebu City", :country => "Philippines", :zip => "6000", :address_type => "current", :person_id => @person.id)
      a.save
      assert_equal "Cebu City<br/>6000<br/>Philippines", Address.last.to_s
      assert_equal "Cebu City<br/>6000<br/>Philippines", Address.last.display_html
    end
    
    should "output correct text if address1 and 2 are not present" do
      a = Address.new(:zip => "6000", :country => "Philippines", :address_type => "current", :person_id => @person.id)
      a.save
      assert_equal "6000<br/>Philippines", Address.last.to_s
      assert_equal "6000<br/>Philippines", Address.last.display_html
    end
  end
  
  should "create map link" do
    @person = Factory(:person)
    a = Address.new(:address1 => "Cebu City", :country => "Philippines", :zip => "6000", :address_type => "current", :person_id => @person.id)
    a.save
    
    assert_equal "http://maps.google.com/maps?f=q&source=s_q&hl=en&q=Cebu City+6000+Philippines", Address.last.map_link
  end
  
end
