require 'test_helper'
class PersonTest < ActiveSupport::TestCase
  context "get_unnotified_transfers" do
    setup do
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
    end
    should "return person transfers with 'notified' = false" do
      transfer1 = Factory(:person_transfer, person: @person1)
      transfer2 = Factory(:person_transfer, person: @person2)
      transfer3 = Factory(:person_transfer, person: @person3)
      results = Batch.get_unnotified_transfers
      assert_equal(results.count, 3, "results should be 3 records")
    end
    should "not return person transfers with 'notified' = true" do
      transfer1 = Factory(:person_transfer, person: @person1, notified: true)
      transfer2 = Factory(:person_transfer, person: @person2)
      transfer3 = Factory(:person_transfer, person: @person3)
      results = Batch.get_unnotified_transfers
      assert(!results.include?(transfer1), "transfer1 should not be returned")
      assert_equal(results.count, 2, "results should be 2 records")
    end
  end
  context "person_transfer_notify" do
    setup do
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
    end
    should "notify person_transfer with 'notified' = false" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org2, role: Role.admin)
      
      transfer1 = Factory(:person_transfer, person: @person1, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
      transfer2 = Factory(:person_transfer, person: @person2, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
        
      results = Batch.person_transfer_notify
      transfer1.reload
      transfer2.reload
      assert_equal(transfer1.notified, true, "notified should be true")
      assert_equal(transfer2.notified, true, "notified should be true")
    end
    should "not notify person_transfer with deleted org" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      
      transfer1 = Factory(:person_transfer, person: @person1, new_organization_id: 99999, 
        old_organization: @org1, transferred_by: @admin)
      transfer2 = Factory(:person_transfer, person: @person2, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
        
      assert_equal(false, transfer1.notified, "notified should be false")
      assert_equal(false, transfer2.notified, "notified should be false")
      results = Batch.person_transfer_notify
      transfer1.reload
      transfer2.reload
      assert_equal(false, transfer1.notified, "notified should be false")
      assert_equal(true, transfer2.notified, "notified should be true")
    end
    should "not notify person_transfer with 'notified' = true" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org2, role: Role.admin)
      
      transfer1 = Factory(:person_transfer, person: @person1, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
      transfer2 = Factory(:person_transfer, person: @person2, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin, notified: true)
        
      assert_equal(transfer1.notified, false, "notified should be false")
      assert_equal(transfer2.notified, true, "notified should be true")
      results = Batch.person_transfer_notify
      transfer1.reload
      transfer2.reload
      assert_equal(transfer1.notified, true, "notified should be true")
      assert_equal(transfer2.notified, true, "notified should be true")
    end
    should "not notify person_transfer from org with admin without email and raise an error" do
      @admin = Factory(:person)
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org2, role: Role.admin)
      
      transfer1 = Factory(:person_transfer, person: @person1, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
      transfer2 = Factory(:person_transfer, person: @person2, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
        
      exception = assert_raise RuntimeError do
        results = Batch.person_transfer_notify
      end
      transfer1.reload
      transfer2.reload
      assert_equal(transfer1.notified, false, "notified should be false")
      assert_equal(transfer2.notified, false, "notified should be false")
    end
    should "not notify person_transfer from org without admin and raise an error" do
      transfer1 = Factory(:person_transfer, person: @person1, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
      transfer2 = Factory(:person_transfer, person: @person2, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
        
      exception = assert_raise RuntimeError do
        results = Batch.person_transfer_notify
      end
      transfer1.reload
      transfer2.reload
      assert_equal(transfer1.notified, false, "notified should be false")
      assert_equal(transfer2.notified, false, "notified should be false")
    end
    should "not notify person_transfer with invalid person" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org2, role: Role.admin)
      transfer1 = Factory(:person_transfer, person_id: 0, new_organization: @org2, 
        old_organization: @org1, transferred_by: @admin)
        
      results = Batch.person_transfer_notify
      transfer1.reload
      assert_equal(transfer1.notified, true, "notified should be true without error raised")
    end
  end
  context "get_unnotified_new_contacts" do
    setup do
      @org = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
    end
    should "return new person with 'notified' = false" do
      transfer1 = Factory(:new_person, person: @person1, organization: @org)
      transfer2 = Factory(:new_person, person: @person2, organization: @org)
      transfer3 = Factory(:new_person, person: @person3, organization: @org)
      results = Batch.get_unnotified_new_contacts
      assert_equal(results.count, 3, "results should be 3 records")
    end
    should "not return new person with 'notified' = true" do
      transfer1 = Factory(:new_person, person: @person1, organization: @org, notified: true)
      transfer2 = Factory(:new_person, person: @person2, organization: @org)
      transfer3 = Factory(:new_person, person: @person3, organization: @org)
      results = Batch.get_unnotified_new_contacts
      assert(!results.include?(transfer1), "transfer1 should not be returned")
      assert_equal(results.count, 2, "results should be 2 records")
    end
  end
  context "new_person_notify" do
    setup do
      @org1 = Factory(:organization)
      @org2 = Factory(:organization)
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
    end
    should "notify new_person with 'notified' = false" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      
      newperson1 = Factory(:new_person, person: @person1, organization: @org1)
      newperson2 = Factory(:new_person, person: @person2, organization: @org1)
      
      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, "notified should be true")
      assert_equal(newperson2.notified, true, "notified should be true")
    end
    should "not notify new_person with deleted org" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      
      newperson1 = Factory(:new_person, person: @person1, organization: @org1)
      newperson2 = Factory(:new_person, person: @person2, organization_id: 99999)
      
      assert_equal(newperson1.notified, false, "notified should be false")
      assert_equal(newperson2.notified, false, "notified should be false")
      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, "notified should be true")
      assert_equal(newperson2.notified, false, "notified should be false")
    end
    should "not notify new_person with 'notified' = true" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      
      newperson1 = Factory(:new_person, person: @person1, organization: @org1)
      newperson2 = Factory(:new_person, person: @person2, organization: @org1, notified: true)
      
      assert_equal(newperson1.notified, false, "notified should be false")
      assert_equal(newperson2.notified, true, "notified should be true")
      results = Batch.new_person_notify
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, true, "notified should be true")
      assert_equal(newperson2.notified, true, "notified should be true")
    end
    should "not notify new_person from org with admin without email and raise an error" do
      @admin = Factory(:person)
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      
      newperson1 = Factory(:new_person, person: @person1, organization: @org1)
      newperson2 = Factory(:new_person, person: @person2, organization: @org1)
      
      exception = assert_raise RuntimeError do
        results = Batch.new_person_notify
      end
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, false, "notified should be true")
      assert_equal(newperson2.notified, false, "notified should be true")
    end
    should "not notify new_person from org without admin and raise an error" do
      newperson1 = Factory(:new_person, person: @person1, organization: @org1)
      newperson2 = Factory(:new_person, person: @person2, organization: @org1)
      
      exception = assert_raise RuntimeError do
        results = Batch.new_person_notify
      end
      newperson1.reload
      newperson2.reload
      assert_equal(newperson1.notified, false, "notified should be false")
      assert_equal(newperson2.notified, false, "notified should be false")
    end
    should "not notify new_person with invalid peron" do
      @admin = Factory(:person)
      @admin_email = @admin.email_addresses.create(email: 'admin@email.com')
      @admin_role = Factory(:organizational_role, person: @admin, organization: @org1, role: Role.admin)
      newperson1 = Factory(:new_person, person_id: 0, organization: @org1)
        
      results = Batch.new_person_notify
      newperson1.reload
      assert_equal(newperson1.notified, true, "notified should be true without error raised")
    end
  end
end
