class Message < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  include Sidekiq::Worker
  sidekiq_options unique: true

  attr_accessible :bulk_message, :from, :message, :organization_id, :person_id, :receiver_id, :sent_via, :subject, :to, :reply_to, :sent
  stores_emoji_characters :subject, :message

  belongs_to :bulk_message
  belongs_to :organization
  belongs_to :sender, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :receiver, class_name: 'Person', foreign_key: 'receiver_id'
  has_one :sent_sms

  # after_create :process_message

  def date_sent
    if ((Time.new - created_at) / 1.day).to_i < 1
      "#{distance_of_time_in_words_to_now(created_at).gsub('about', '').strip} ago"
    else
      created_at.strftime('%b %d, %H:%S')
    end
  end

  def self.outbound_text_messages(phone_number)
    where("(`messages`.to = ? AND sent_via = 'sms') OR (`messages`.reply_to LIKE ? AND sent_via = 'sms_email')", phone_number, "#{phone_number}%")
  end

  def status
    if sent_via == 'sms'
      sent_sms.present? ? sent_sms.status : 'none'
    else
      'sent'
    end
  end

  def process_message
    case sent_via
    when 'sms_email'
      SmsMailer.text(to, from, message, reply_to)
      return true
    when 'sms'
      sent_sms = SentSms.create(message_id: id, message: message, recipient: to, sent_via: organization.sms_gateway)
      return sent_sms.send_sms
    when 'email'
      PeopleMailer.bulk_message(to, from, subject, message, sender).deliver_later
      return true
    end
  end

  def perform(msg_id)
    msg = Message.find(msg_id)
    if msg.sent_via == 'sms' && msg.status != 'sent'
      msg.update!(sent: true) if msg.process_message
    end
  end
end
