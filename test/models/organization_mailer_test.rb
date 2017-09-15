require 'test_helper'

class OrganizationMailerTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user_with_auxs)
    FactoryGirl.create(:email_address, person: @user.person)
    @user.person.reload
    @org = @user.person.organizations.first
  end

  test 'notify admin of request' do
    OrganizationMailer.notify_admin_of_request(@org).deliver_now
    content = ActionMailer::Base.deliveries.last
    assert_match /New organization request/, content.subject.to_s
  end
end
