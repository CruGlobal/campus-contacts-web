require 'spec_helper'

describe MailChimpSyncWorker, '#perform' do
  before :all do
    User.delete_all
  end

  it 'subscribes users signed in recently' do
    org = create(:organization)
    user = create(:user_api, sign_in_count: 1, current_sign_in_at: 1.day.ago)
    user.person.primary_email_address.update(email: 'bill@cru.org')
    create(:organizational_permission, person: user.person, organization: org, permission: Permission.admin)
    create_member =
      stub_request(:put, 'https://apikey:asdf-us6@us6.api.mailchimp.com/3.0/'\
                   'lists/asdf/members/30d710c122bcb71900c32f5b29a98ea5')

    subject.perform

    expect(user.reload.subscribed_to_updates).to be true
    expect(create_member).to have_been_requested
  end

  it 'unsubscribes users signed in a while ago' do
    user = create(:user_api, sign_in_count: 1, subscribed_to_updates: true,
                             current_sign_in_at: (MailChimpSyncWorker::CURRENT_USER_RANGE - 1.day))
    user.person.primary_email_address.update(email: 'bill@cru.org')
    delete_member =
      stub_request(:delete, 'https://apikey:asdf-us6@us6.api.mailchimp.com/3.0/'\
                   'lists/asdf/members/30d710c122bcb71900c32f5b29a98ea5')

    subject.perform

    expect(user.reload.subscribed_to_updates).to be_nil
    expect(delete_member).to have_been_requested
  end
end
