class Message < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  attr_accessible :from, :message, :organization_id, :person_id, :receiver_id, :sent_via, :subject, :to, :reply_to

  belongs_to :organization
  belongs_to :sender, class_name: "Person", foreign_key: "person_id"
  belongs_to :receiver, class_name: "Person", foreign_key: "receiver_id"

  after_create :process_message

  def date_sent
    if ((Time.new - created_at) / 1.day).to_i < 1
      "#{distance_of_time_in_words_to_now(created_at).gsub('about','').strip} ago"
    else
      created_at.strftime('%b %d, %H:%S')
    end
  end

  private

  def process_message
    case sent_via
    when 'sms_email'
      SmsMailer.enqueue.text(to, from, message, reply_to)
    when 'sms'
      sent_sms = SentSms.create!(message: message, recipient: to, sent_via: organization.sms_gateway)
      sent_sms.queue_sms
    when 'email'
      PeopleMailer.enqueue.bulk_message(to, from, subject, message, reply_to)
    end
  end
end
