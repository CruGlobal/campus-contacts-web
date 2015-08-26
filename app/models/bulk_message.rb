require 'async'
class BulkMessage < ActiveRecord::Base
  include Async
  include Sidekiq::Worker
  sidekiq_options unique: true

  attr_accessible :person_id, :organization_id, :status, :results

  serialize :results
  belongs_to :person
  belongs_to :organization
  has_many :messages

  def do_process
    async(:process)
  end

  def process
    bulk_message = BulkMessage.find_by_id(id)
    if bulk_message.present? && bulk_message.messages.present?
      return bulk_message if bulk_message.status == 'completed'
      message = bulk_message.messages.first.message
      bulk_message.update_attributes(status: 'processing')
      with_failure = false
      results = Array.new
      proper = 0
      bulk_message.messages.each do |msg|
        if msg.sent_via == 'sms'
          receiver = PhoneNumber.prettify(msg.to)
          receiver_name = msg.receiver.present? ? msg.receiver.name : "Unknown"
          if msg.status != 'sent'
            is_sent = msg.process_message
            proper = 1
            results << {id: msg.id, receiver_name: receiver_name, to: receiver, type: msg.sent_via, is_sent: is_sent}
            with_failure = true unless is_sent
          else
            results << {id: msg.id, receiver_name: receiver_name, to: receiver, type: msg.sent_via, is_sent: msg.status == 'sent'}
          end
        end
      end
      bulk_message.update_attributes(status: 'completed', results: results)
      # raise "(#{proper}) Intentional error for testing: #{with_failure.inspect}"
      PeopleMailer.notify_on_bulk_sms_failure(bulk_message.person, results, bulk_message, message).deliver! if with_failure
      return bulk_message
    elsif bulk_message.present?
      bulk_message.update_attributes(status: 'failed', results: nil)
      return bulk_message
    end
  end
end
