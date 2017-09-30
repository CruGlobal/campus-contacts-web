require 'spec_helper'

describe SubscriptionSmsSession do
  before do
    @organization1 = FactoryGirl.create(:organization)
    @organization2 = FactoryGirl.create(:organization)

    @person = FactoryGirl.create(:person)
    @session = FactoryGirl.create(:subscription_sms_session, phone_number: 1, person: @person)

    @unsubscribe1 = FactoryGirl.create(:sms_unsubscribe, organization: @organization1)
    @unsubscribe2 = FactoryGirl.create(:sms_unsubscribe, organization: @organization2)
  end

  it 'creates choices' do
    allow(SubscriptionChoice).to receive(:create!)

    @session.create_choices([@unsubscribe1, @unsubscribe2])

    expect(SubscriptionChoice).to have_received(:create!).with(organization_id: anything, subscription_sms_session_id: anything, value: 1)
    expect(SubscriptionChoice).to have_received(:create!).with(organization_id: anything, subscription_sms_session_id: anything, value: 2)
  end

  context '#subscribe' do
    before do
      @value = 3
      FactoryGirl.create(:subscription_choice, organization: @organization1, subscription_sms_session: @session, value: @value)
    end
    it 'subscribes based on choice' do
      allow(SmsUnsubscribe).to receive(:remove_from_unsubscribe)

      @session.subscribe(@value)

      expect(SmsUnsubscribe).to have_received(:remove_from_unsubscribe)
    end

    it 'returns message' do
      result = @session.subscribe(@value)

      expect(result).to eq("You have been subscribed from MHub text alerts. You can now receive text messages from #{@organization1.name}.")
    end
  end
end
