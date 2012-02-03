require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  should belong_to(:related_question_sheet)
  should have_many(:conditions)
  should have_many(:dependents)
  should have_many(:sheet_answers)
  
  context "Send notifications" do
    setup do
      @element = Factory(:choice_field, label: 'foobar', notify_via: "Both", trigger_words: "my answer")
      @element2 = Factory(:choice_field, label: 'foobarbaz', notify_via: "Email", trigger_words: "my answer")
      @element3 = Factory(:choice_field, label: 'foo', notify_via: "SMS", trigger_words: "my answer")
      @person = Factory(:person, firstName: "Herp", lastName: "Derp", email: "herp_derp@gmail.com", phone_number: "101011011")
      @question = Question.new
    end

    should "send notifications via email and sms" do
      assert @question.send_notifications(@element, @person, "my answer")
    end
    
    should "send notifications via email only" do
      assert @question.send_notifications(@element2, @person, "my answer")
    end

    should "send notifications via sms only" do
      assert @question.send_notifications(@element3, @person, "my answer")
    end

    should "shorten the link compose the message properly then send to leaders" do
      short_link = @question.shorten_link(@person.id)
      #check shortened link
      assert(short_link.include? "bit.ly")
      #generate message
      msg = "Herp Derp (101011011, herp_derp@gmail.com) just replied to a survey with my answer. Profile link: #{short_link}"
      #message should be correct
      assert_equal(msg,@question.generate_notification_msg(@person, "my answer", short_link))
      #should send sms
      assert @question.send_sms_to_leaders(@question.leaders, msg)
      #should send emails
      assert @question.send_email_to_leaders(@question.leaders, msg)
    end
  end
end
