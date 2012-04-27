require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should belong_to(:person)
  should validate_presence_of(:number)
  # should validate_presence_of(:person_id)
  # should validate_presence_of(:location)

  context "a phone number" do
    setup do 
      @person = Factory(:person)
    end
    should "set first number to primary" do
      number = @person.phone_numbers.create(number: '555-555-5555', location: 'mobile')
      assert(!number.new_record?, number.errors.full_messages.join(','))
      assert(number.primary?, "number should be primary")
    end

    should "set new primary when primary number is deleted" do
      person = Factory(:person)
      number1 = @person.phone_numbers.create(number: '555-555-5555', location: 'mobile')
      assert(!number1.new_record?, number1.errors.full_messages.join(','))
      number2 = PhoneNumber.create!(number: '444-444-4444', location: 'fooo', person_id: @person.id)
      assert(!number2.new_record?, number2.errors.full_messages.join(','))
      assert_equal(number2.person, number1.person)
      assert(number1.primary?, "first number should be primary")
      number1.destroy
      number2.reload
      assert(number2.primary?, "second number should be primary")
    end
  
    should "should store as digits only" do
      number = @person.phone_numbers.create(number: '555-555-5555', location: 'mobile')
      assert_equal('5555555555', number.number)
      number = @person.phone_numbers.create(number: '555-5555', location: 'mobile')
      assert_equal('5555555', number.number)
    end
    
    should "have a pretty format" do
      number = @person.phone_numbers.create(number: '555-555-5555', location: 'mobile')
      assert_equal('(555) 555-5555', number.pretty_number)
      number = @person.phone_numbers.create(number: '555-5555', location: 'mobile')
      assert_equal('555-5555', number.pretty_number)
      number = @person.phone_numbers.create(number: '555-555', location: 'mobile')
      assert_equal('555555', number.pretty_number)
    end
  end
  
  test "normalize carrier" do
    person = Factory(:person)
    p = PhoneNumber.create!(number: '444-444-4444', location: 'fooo', person_id: person.id)
    assert_equal 'verizon', p.send(:normalize_carrier, "VERIZON")
    assert_equal 'verizon', p.send(:normalize_carrier, "BELL ATLANTIC")
    assert_equal 'cingular', p.send(:normalize_carrier, "CINGULAR")
    assert_equal 'nextel', p.send(:normalize_carrier, "NEXTEL")
    assert_equal 't-mobile', p.send(:normalize_carrier, "T-MOBILE")
    assert_equal 'western wireless', p.send(:normalize_carrier, "WESTERN WIRELESS")
    assert_equal 'omnipoint', p.send(:normalize_carrier, "OMNIPOINT")
    assert_equal 'powertel', p.send(:normalize_carrier, "POWERTEL")
    assert_equal 'alltel', p.send(:normalize_carrier, "ALLTEL")
    assert_equal 'cricket', p.send(:normalize_carrier, "CRICKET")
    assert_equal 'us cellular', p.send(:normalize_carrier, "UNITED STATES CELLULAR")
    assert_equal 'eltopia', p.send(:normalize_carrier, "ELTOPIA COMMUNICATIONS")
    assert_equal 'ameritech', p.send(:normalize_carrier, "AMERITECH")
    assert_equal 'bell south', p.send(:normalize_carrier, "SOUTHERN BELL")
    assert_equal 'bell south', p.send(:normalize_carrier, "BELLSOUTH")
    assert_equal 'SOUTHWESTERN BELL', p.send(:normalize_carrier, "SOUTHWESTERN BELL")
    assert_equal 'CINCINNATI BELL', p.send(:normalize_carrier, "CINCINNATI BELL")
    assert_equal 'CELLCOM', p.send(:normalize_carrier, "CELLCOM")
    assert_equal 'METRO PCS', p.send(:normalize_carrier, "METRO PCS")
    assert_equal 'METRO PCS', p.send(:normalize_carrier, "METRO SOUTHWEST PCS")
    assert_equal 'xo', p.send(:normalize_carrier, "XO")
    assert_equal "BANDWIDTH.COM", p.send(:normalize_carrier, "BANDWIDTH.COM")
    assert_equal "LEVEL 3 COMMUNICATIONS", p.send(:normalize_carrier, "LEVEL 3 COMMUNICATIONS")
    assert_equal "CENTURYTEL", p.send(:normalize_carrier, "CENTURYTEL")
    assert_equal "360NETWORKS", p.send(:normalize_carrier, "360NETWORKS")
    assert_equal "ACS", p.send(:normalize_carrier, "ACS")
    assert_equal "BROADWING", p.send(:normalize_carrier, "BROADWING")
    assert_equal "CABLEVISION", p.send(:normalize_carrier, "CABLEVISION")
    assert_equal "CENTENNIAL", p.send(:normalize_carrier, "CENTENNIAL")
    assert_equal "CENTRAL", p.send(:normalize_carrier, "CENTRAL")
    assert_equal "CHARTER FIBERLINK", p.send(:normalize_carrier, "CHARTER FIBERLINK")
    assert_equal "CHOICE ONE COMMUNICATIONS", p.send(:normalize_carrier, "CHOICE ONE COMMUNICATIONS")
    assert_equal "FRONTIER", p.send(:normalize_carrier, "FRONTIER")
    assert_equal "FRONTIER", p.send(:normalize_carrier, "CITIZENS")
    assert_equal "CITYNET", p.send(:normalize_carrier, "CITYNET")
    assert_equal "COMCAST", p.send(:normalize_carrier, "COMCAST")
    assert_equal "COMMPARTNERS", p.send(:normalize_carrier, "COMMPARTNERS")
    assert_equal "COX", p.send(:normalize_carrier, "COX")
    assert_equal "DELTACOM", p.send(:normalize_carrier, "DELTACOM")
    assert_equal "EMBARQ", p.send(:normalize_carrier, "EMBARQ")
    assert_equal "ESCHELON", p.send(:normalize_carrier, "ESCHELON")
    assert_equal "GLOBAL CROSSING", p.send(:normalize_carrier, "GLOBAL CROSSING")
    assert_equal "ICG TELECOM", p.send(:normalize_carrier, "ICG TELECOM")
    assert_equal "INTERMEDIA", p.send(:normalize_carrier, "INTERMEDIA")
    assert_equal 'mci', p.send(:normalize_carrier, "MCI WORLDCOM")
    assert_equal 'mci', p.send(:normalize_carrier, "MCIMETRO")
    assert_equal "MPOWER", p.send(:normalize_carrier, "MPOWER")
    assert_equal "NUVOX COMMUNICATIONS", p.send(:normalize_carrier, "NUVOX COMMUNICATIONS")
    assert_equal "PAC - WEST TELECOMM", p.send(:normalize_carrier, "PAC - WEST TELECOMM")
    assert_equal "pacific bell", p.send(:normalize_carrier, "PACIFIC BELL")
    assert_equal "PAETEC COMMUNICATIONS", p.send(:normalize_carrier, "PAETEC COMMUNICATIONS")
    assert_equal "RCN", p.send(:normalize_carrier, "RCN")
    assert_equal "att", p.send(:normalize_carrier, "AT&T")
    assert_equal "SUREWEST", p.send(:normalize_carrier, "SUREWEST")
    assert_equal "TELCOVE", p.send(:normalize_carrier, "TELCOVE")
    assert_equal "TIME WARNER", p.send(:normalize_carrier, "TIME WARNER")
    assert_equal "TW TELECOM", p.send(:normalize_carrier, "TW TELECOM")
    assert_equal "UNITED TEL", p.send(:normalize_carrier, "UNITED TEL")
    assert_equal "US LEC", p.send(:normalize_carrier, "US LEC")
    assert_equal "WINDSTREAM", p.send(:normalize_carrier, "WINDSTREAM")
    assert_equal "YMAX COMMUNICATIONS", p.send(:normalize_carrier, "YMAX COMMUNICATIONS")
    assert_equal nil, p.send(:normalize_carrier, "WAT")
  end
end
