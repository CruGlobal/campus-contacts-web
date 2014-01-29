require 'test_helper'

class LeaderMailerTest < ActionMailer::TestCase

  context "When OrganizationalPermission with leader permission is created" do
    should "email the new leader" do
      user1 = Factory(:user_with_auxs)
      user1.person.email = 'test@uscm.org'
      user1.person.save
      user2 = Factory(:user_with_auxs)
      user2.person.email = 'test2@uscm.org'
      user2.person.save
      org = Factory(:organization)
      assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1, "No email is being sent after leader is added.") do
        Factory(:organizational_permission, person: user1.person, permission: Permission.user, organization: org, :added_by_id => user2.person.id)
      end
    end

    should "successfully email a Person (Contact), even though Person does not have a User, because a User is created for a Person (Contact that will be assigned as leader) if Person does not have a User" do
      person1 = Factory(:person_with_things)
      person1.email = "neil@email.com"
      person1.save
      user2 = Factory(:user_with_auxs)
      user2.person.email = 'test2@uscm.org'
      user2.person.save
      org = Factory(:organization)
      assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1, "No email is being sent after leader is added.") do
        Factory(:organizational_permission, person: person1, permission: Permission.user, organization: org, :added_by_id => user2.person.id)
      end
    end
  end
end
