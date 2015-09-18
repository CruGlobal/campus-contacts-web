require 'test_helper'

class BulkMessagesControllerTest < ActionController::TestCase

  context "bulk sending" do
    setup do
      @user, @org = admin_user_login_with_org
      sign_in @user
      @person = @user.person
      @person1 = FactoryGirl.create(:person_without_email)
      @org.add_contact(@person1)
      @person2 = FactoryGirl.create(:person_without_email)
      @org.add_contact(@person2)
      PhoneNumber.create(:number => "123129312", :person_id => @person1.id)
      PhoneNumber.create(:number => "12390900", :person_id => @person2.id, :primary => true)

      stub_request(:post, /.*api.twilio.com\/.*/).
        with(:headers => {'Accept'=>'application/json', 'Accept-Charset'=>'utf-8', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(:status => 200, :body => "{\"sid\": \"#{sid = rand(36**36).to_s(36)}\", \"date_created\": \"#{timestamp = Time.now}\", \"date_updated\": \"#{timestamp}\", \"date_sent\": null, \"account_sid\": \"#{tid = ENV.fetch('TWILIO_ID')}\", \"to\": \"+1234567890\", \"from\": \"85005\", \"body\": \"This is test message, please ignore.\", \"status\": \"queued\", \"num_segments\": \"1\", \"num_media\": \"0\", \"direction\": \"outbound-api\", \"api_version\": \"2010-04-01\", \"price\": null, \"price_unit\": \"USD\", \"error_code\": null, \"error_message\": null, \"uri\": \"/2010-04-01/Accounts/#{tid}/Messages/#{sid}.json\", \"subresource_uris\": {\"media\": \"/2010-04-01/Accounts/#{tid}/Messages/#{sid}/Media.json\"}}", :headers => {})
    end

    should "send bulk sms" do
      Sidekiq::Testing.inline! do
        assert_difference "SentSms.count", +2 do
          assert_difference "BulkMessage.count", +1 do
            xhr :post, :sms, { :to => "#{@person1.id},#{@person2.id}", :body => "test sms body" }
            assert_response :success
          end
        end
      end
    end

    should "send bulk SMS via twilio (default)" do
      Sidekiq::Testing.inline! do
        assert_difference "SentSms.count", +2 do
          assert_difference "BulkMessage.count", +1 do
            xhr :post, :sms, { :to => "#{@person1.id},#{@person2.id}", :body => "test sms body" }
            assert_response :success
          end
        end
        assert_equal 'twilio', SentSms.last.sent_via
      end
    end

    should "send bulk SMS via smseco" do
      @org.settings[:sms_gateway] = 'smseco'
      @org.save
      stub_request(:get, /http:\/\/www.smseco.com\/.*/).
        with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => "", :headers => {})
      Sidekiq::Testing.inline! do
        assert_difference "SentSms.count", +2 do
          assert_difference "BulkMessage.count", +1 do
            xhr :post, :sms, { :to => "#{@person1.id},#{@person2.id}", :body => "test sms body" }
          end
          BulkMessage.last.process
        end
        assert_equal 'smseco', SentSms.last.sent_via
      end
    end
  end
end
