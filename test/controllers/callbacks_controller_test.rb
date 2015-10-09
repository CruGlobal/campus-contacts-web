require 'test_helper'

class CallbacksControllerTest < ActionController::TestCase
  context 'Callbacks' do
    context 'for Twilio' do
      setup do
        @person = FactoryGirl.create(:person_without_email)
        @org = FactoryGirl.create(:organization)
        @org.add_contact(@person)
        PhoneNumber.create(number: '123129312', person_id: @person.id)
      end

      should 'update message status into sent' do
        message = Message.create(
          bulk_message: nil,
          receiver_id: @person.id,
          organization_id: @org.id,
          to: '123129312',
          sent_via: 'sms',
          message: 'Hello'
        )
        SentSms.create(
          message_id: message.id,
          message: 'Hello',
          recipient: '123129312',
          sent_via: 'twilio',
          twilio_sid: 'SM3511fe0de8aa4e8eb4a40243aa0d8b97',
          status: 'queued'
        )
        post :twilio_status, MessageSid: 'SM3511fe0de8aa4e8eb4a40243aa0d8b97', MessageStatus: 'sent'
        assert_equal 'sent', SentSms.last.status, "Sent SMS should have 'sent' status"
      end
    end
  end
end
