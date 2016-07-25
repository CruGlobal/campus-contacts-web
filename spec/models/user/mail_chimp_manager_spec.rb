require 'spec_helper'

describe User::MailChimpManager do
  before :all do
    User.delete_all
  end

  context '#subscribe' do
    it 'does not error on a 400 message about an invalid email address' do
      user = create(:user_api, subscribed_to_updates: true)
      user.person.primary_email_address.update(email: '1@test.com')
      email = user.person.email
      url = 'https://apikey:asdf-us6@us6.api.mailchimp.com/3.0/'\
        'lists/asdf/members/b54d4e8f3fc1192d51c1a77a9ee3a9a5'

      err = "#{email} looks fake or invalid, please enter a real email address."
      create_request = stub_request(:put, url)
                       .to_return(status: 400, body: { detail: err }.to_json)

      User::MailChimpManager.new(user).subscribe

      expect(user.reload.subscribed_to_updates).to be false
      expect(create_request).to have_been_made
    end
  end

  context '#unsubscribe' do
    it 'does not error on a 404 message but marks user as unsubscribed' do
      user = create(:user_api, subscribed_to_updates: true)
      user.person.primary_email_address.update(email: '2@test.com')
      url = 'https://apikey:asdf-us6@us6.api.mailchimp.com/3.0/'\
        'lists/asdf/members/bcd4d679542fc3de3f43022db9dece56'
      delete_request = stub_request(:delete, url).to_return(status: 404)

      User::MailChimpManager.new(user).unsubscribe

      expect(user.reload.subscribed_to_updates).to be_nil
      expect(delete_request).to have_been_made
    end
  end
end
