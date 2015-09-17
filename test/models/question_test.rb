require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  should belong_to(:related_question_sheet)
  should have_many(:sheet_answers)

  context "Send notifications" do
    setup do
      # File.new(Rails.root.join("test/fixtures/bitly.txt"))
      @element = FactoryGirl.create(:choice_field, label: 'foobar', notify_via: "Both", trigger_words: "my answer")
      @element2 = FactoryGirl.create(:choice_field, label: 'foobarbaz', notify_via: "Email", trigger_words: "my answer")
      @element3 = FactoryGirl.create(:choice_field, label: 'foo', notify_via: "SMS", trigger_words: "my answer")
      @person = FactoryGirl.create(:person, first_name: "Herp", last_name: "Derp", email: "herp_derp@gmail.com", phone_number: "101011011")
      @question = Question.new

      # stub_request(:get, "http://api.bit.ly/shorten?apiKey=bitlykey&history=&login=vincentpaca&longUrl=http://www.missionhub.com/people/86505&version=2.0.1").
      #   with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'api.bit.ly', 'User-Agent'=>'Ruby'}).
      #   to_return(status: 200, body: "", headers: {})

      # stub_request(:get, "https://api-ssl.bitly.com/v3/shorten?access_token=bitlykey&longUrl=http://www.missionhub.com/people/#{@person.id}").
      #   to_return(:body => "{\"status_code\":\"200\", \"status_txt\":\"OK\", \"data\": {\"long_url\": \"http:\/\/www.missionhub.com\/people\/7971\", \"url\": \"http:\/\/bit.ly\/QG64KU\", \"hash\": \"QG64KU\", \"global_hash\": \"QG64KV\", \"new_hash\":\"0\"}}", :status => 200)
      stub_request(:get, "https://api-ssl.bitly.com/v3/shorten?access_token=#{ENV['BITLY_KEY']}&longUrl=http://www.missionhub.com/people/#{@person.id}").
        to_return(:body => "{\"status_code\":\"200\", \"status_txt\":\"OK\", \"data\": {\"long_url\": \"http:\/\/www.missionhub.com\/people\/7971\", \"url\": \"http:\/\/bit.ly\/QG64KU\", \"hash\": \"QG64KU\", \"global_hash\": \"QG64KV\", \"new_hash\":\"0\"}}", :status => 200)
    end

    should "send notifications via email and sms" do
      assert @question.send_notifications(@element, @person, "my answer")
    end

    # should "send notifications via email only" do
    #   assert @question.send_notifications(@element2, @person, "my answer")
    # end
    #
    # should "send notifications via sms only" do
    #   assert @question.send_notifications(@element3, @person, "my answer")
    # end
    #
    # should "shorten the link compose the message properly then send to leaders" do
    #   short_link = @question.shorten_link(@person.id)
    #   #check shortened link
    #   assert(short_link.include? "bit.ly")
    #   #generate message
    #   msg = "Herp Derp (101011011, herp_derp@gmail.com) just replied to a survey with my answer. Profile link: #{short_link}"
    #   #message should be correct
    #   assert_equal(msg,@question.generate_notification_msg(@person, "my answer", short_link))
    #   #should send sms
    #   assert @question.send_sms_to_leaders(@question.leaders, msg)
    #   #should send emails
    #   assert @question.send_email_to_leaders(@question.leaders, msg)
    # end
  end


end
