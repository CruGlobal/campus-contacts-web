require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should belong_to(:person)
  should validate_presence_of(:number)
  # should validate_presence_of(:person_id)
  should validate_presence_of(:location)

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
end
