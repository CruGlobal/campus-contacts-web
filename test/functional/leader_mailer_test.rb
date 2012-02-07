require 'test_helper'

class LeaderMailerTest < ActionMailer::TestCase
  context "When OrganizationalRole with leader role is created" do
    should "email the new leader" do
      user1 = Factory(:user_with_auxs, email: 'test@uscm.org')
      user2 = Factory(:user_with_auxs, email: 'test2@uscm.org')
      org = Factory(:organization)
      puts Factory(:organizational_role, person: user1.person, role: Role.leader, organization: org, :added_by_id => user2.person.id)
      assert_equal ActionMailer::Base.deliveries.count, 1, "No email is being sent after leader is added."
      assert_equal ActionMailer::Base.deliveries.first.from.first, user2.email, "Wrong sending email after email is sent after leader is added."
      assert_equal ActionMailer::Base.deliveries.first.to.first, user1.email, "Wrong receiving email after email is sent after leader is added."
    end
  end

end
