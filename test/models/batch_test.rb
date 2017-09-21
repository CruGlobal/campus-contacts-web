require 'test_helper'
class PersonTest < ActiveSupport::TestCase
  context 'get_unnotified_new_contacts' do
    setup do
      @org = FactoryGirl.create(:organization)
      @person1 = FactoryGirl.create(:person)
      @person2 = FactoryGirl.create(:person)
      @person3 = FactoryGirl.create(:person)
    end
    should "return new person with 'notified' = false" do
      transfer1 = FactoryGirl.create(:new_person, person: @person1, organization: @org)
      transfer2 = FactoryGirl.create(:new_person, person: @person2, organization: @org)
      transfer3 = FactoryGirl.create(:new_person, person: @person3, organization: @org)
      results = Batch.get_unnotified_new_contacts
      assert_equal(results.count, 3, 'results should be 3 records')
    end
    should "not return new person with 'notified' = true" do
      transfer1 = FactoryGirl.create(:new_person, person: @person1, organization: @org, notified: true)
      transfer2 = FactoryGirl.create(:new_person, person: @person2, organization: @org)
      transfer3 = FactoryGirl.create(:new_person, person: @person3, organization: @org)
      results = Batch.get_unnotified_new_contacts
      assert(!results.include?(transfer1), 'transfer1 should not be returned')
      assert_equal(results.count, 2, 'results should be 2 records')
    end
  end
  context 'new_person_notify' do
    setup do
      @org1 = FactoryGirl.create(:organization)
      @org2 = FactoryGirl.create(:organization)
      @person1 = FactoryGirl.create(:person)
      @person2 = FactoryGirl.create(:person)
      @person3 = FactoryGirl.create(:person)
    end
    should "notify new_person with 'notified' = false" do
      @admin = FactoryGirl.create(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_permission = FactoryGirl.create(:organizational_permission, person: @admin, organization: @org1, permission: Permission.admin)

      newperson1 = FactoryGirl.create(:new_person, person: @person1, organization: @org1)
      newperson2 = FactoryGirl.create(:new_person, person: @person2, organization: @org1)

      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, 'notified should be true')
      assert_equal(newperson2.notified, true, 'notified should be true')
    end
    should 'not notify new_person with deleted org' do
      @admin = FactoryGirl.create(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_permission = FactoryGirl.create(:organizational_permission, person: @admin, organization: @org1, permission: Permission.admin)

      newperson1 = FactoryGirl.create(:new_person, person: @person1, organization: @org1)
      newperson2 = FactoryGirl.create(:new_person, person: @person2, organization_id: 99_999)

      assert_equal(newperson1.notified, false, 'notified should be false')
      assert_equal(newperson2.notified, false, 'notified should be false')
      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, 'notified should be true')
      assert_equal(newperson2.notified, false, 'notified should be false')
    end
    should "not notify new_person with 'notified' = true" do
      @admin = FactoryGirl.create(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_permission = FactoryGirl.create(:organizational_permission, person: @admin, organization: @org1, permission: Permission.admin)

      newperson1 = FactoryGirl.create(:new_person, person: @person1, organization: @org1)
      newperson2 = FactoryGirl.create(:new_person, person: @person2, organization: @org1, notified: true)

      assert_equal(newperson1.notified, false, 'notified should be false')
      assert_equal(newperson2.notified, true, 'notified should be true')
      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, 'notified should be true')
      assert_equal(newperson2.notified, true, 'notified should be true')
    end
    should 'not notify new_person from org with admin without email and raise an error' do
      @admin = FactoryGirl.create(:person)
      @admin_permission = FactoryGirl.create(:organizational_permission, person: @admin, organization: @org1, permission: Permission.admin)
      @admin.email_addresses.destroy_all

      newperson1 = FactoryGirl.create(:new_person, person: @person1, organization: @org1)
      newperson2 = FactoryGirl.create(:new_person, person: @person2, organization: @org1)

      exception = assert_raise RuntimeError do
        results = Batch.new_person_notify
      end
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, false, 'notified should be true')
      assert_equal(newperson2.notified, false, 'notified should be true')
    end
    should 'not notify new_person from org without admin and raise an error' do
      newperson1 = FactoryGirl.create(:new_person, person: @person1, organization: @org1)
      newperson2 = FactoryGirl.create(:new_person, person: @person2, organization: @org1)

      exception = assert_raise RuntimeError do
        results = Batch.new_person_notify
      end
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, false, 'notified should be false')
      assert_equal(newperson2.notified, false, 'notified should be false')
    end
    should 'not notify new_person with invalid peron' do
      @admin = FactoryGirl.create(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_permission = FactoryGirl.create(:organizational_permission, person: @admin, organization: @org1, permission: Permission.admin)
      newperson1 = FactoryGirl.create(:new_person, person_id: 0, organization: @org1)

      results = Batch.new_person_notify
      newperson1.reload
      assert_equal(newperson1.notified, true, 'notified should be true without error raised')
    end
  end
end
