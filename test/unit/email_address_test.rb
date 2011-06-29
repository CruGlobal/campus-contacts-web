require 'test_helper'

class EmailAddressTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  should belong_to(:person)
  should validate_presence_of(:email)
  # should validate_presence_of(:person_id)

  context "an email address" do
    setup do 
      @person = Factory(:person)
    end
    should "set first email to primary" do
      email = @person.email_addresses.create(email: 'test@example.com')
      assert(!email.new_record?, email.errors.full_messages.join(','))
      assert(email.primary?, "email should be primary")
    end

    should "set new primary when primary email is deleted" do
      person = Factory(:person)
      email1 = @person.email_addresses.create(email: 'test@example.com')
      assert(!email1.new_record?, email1.errors.full_messages.join(','))
      email2 = @person.email_addresses.create(email: 'test2@ecample.com')
      assert(!email2.new_record?, email2.errors.full_messages.join(','))
      assert_equal(email2.person, email1.person)
      assert(email1.primary?, "first email should be primary")
      email1.destroy
      email2.reload
      assert(email2.primary?, "second email should be primary")
    end
  end
end
