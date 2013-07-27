require 'test_helper'

class InteractionTest < ActiveSupport::TestCase
  should have_many(:interaction_initiators)
  should have_many(:initiators)
  should belong_to(:organization)
  should belong_to(:interaction_type)
  should belong_to(:receiver)
  should belong_to(:creator)

  context "Interaction feed" do
    setup do
      @parent1 = Factory(:organization, ancestry: nil)
      @parent2 = Factory(:organization, ancestry: "#{@parent1.id}")
      @org1 = Factory(:organization, ancestry: "#{@parent1.id}/#{@parent2.id}")
      @org2 = Factory(:organization)

      @org1admin1 = Factory(:person)
      Factory(:organizational_permission, organization: @org1, person: @org1admin1, permission: Permission.admin)
      @org1admin2 = Factory(:person)
      Factory(:organizational_permission, organization: @org1, person: @org1admin2, permission: Permission.admin)
      @org1contact = Factory(:person)
      Factory(:organizational_permission, organization: @org1, person: @org1contact, permission: Permission.no_permissions)
      
      @org2admin1 = Factory(:person)
      Factory(:organizational_permission, organization: @org2, person: @org2admin1, permission: Permission.admin)
      @org2contact = Factory(:person)
      Factory(:organizational_permission, organization: @org2, person: @org2contact, permission: Permission.no_permissions)
      
      @parent1admin1 = Factory(:person)
      Factory(:organizational_permission, organization: @parent1, person: @parent1admin1, permission: Permission.admin)
      @parent1contact = Factory(:person)
      Factory(:organizational_permission, organization: @parent1, person: @parent1contact, permission: Permission.no_permissions)
      
      @parent2admin1 = Factory(:person)
      Factory(:organizational_permission, organization: @parent2, person: @parent2admin1, permission: Permission.admin)
      @parent2contact = Factory(:person)
      Factory(:organizational_permission, organization: @parent2, person: @parent2contact, permission: Permission.no_permissions)
      
      @interaction1 = Factory(:interaction, organization: @org1, creator: @org1admin1, receiver: @org1contact)
    end
    
    context "privacy_setting = 'everyone'" do
      setup do
        @interaction1.update_attribute(:privacy_setting,'everyone')
      end
      should "be visible to other admin from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin2,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to admin from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to a contact from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to a contact from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
    end
    
    context "privacy_setting = 'parent'" do
      setup do
        @interaction1.update_attribute(:privacy_setting,'parent')
      end
      should "be visible to other admin from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin2,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to admin from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "be visible to a contact from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to a contact from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "be visible to admin from the parent org" do
        displayed_feeds = @org1contact.filtered_interactions(@parent2admin1,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to contact from the parent org" do
        displayed_feeds = @org1contact.filtered_interactions(@parent2contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to admin from the another parent org" do
        displayed_feeds = @org1contact.filtered_interactions(@parent1admin1,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be visible to contact from the another parent org" do
        displayed_feeds = @org1contact.filtered_interactions(@parent1contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to admin from the non-parent org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
    end
    
    context "privacy_setting = 'organization'" do
      setup do
        @interaction1.update_attribute(:privacy_setting,'organization')
      end
      should "be visible to other admin within the org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin2,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to admin from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "be visible to a contact from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1contact,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to contact from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
    end
    
    context "privacy_setting = 'admins'" do
      setup do
        @interaction1.update_attribute(:privacy_setting,'admins')
      end
      should "be visible to other admin within the org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin2,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "not be visible to admin from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "not be visible to a contact from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "not be visible to contact from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
    end
    
    context "privacy_setting = 'me'" do
      setup do
        @interaction1.update_attribute(:privacy_setting,'me')
      end
      should "be visible to the admin who created it" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin1,@org1)
        assert displayed_feeds.include?(@interaction1), "Interaction should be returned"
      end
      should "be not visible to other admin within the org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1admin2,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "be not visible to admin from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2admin1,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "not be visible to a contact from the same org" do
        displayed_feeds = @org1contact.filtered_interactions(@org1contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
      should "not be visible to contact from the other org" do
        displayed_feeds = @org1contact.filtered_interactions(@org2contact,@org1)
        assert !displayed_feeds.include?(@interaction1), "Interaction should not be returned"
      end
    end
  end
  
end
