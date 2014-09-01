require 'async'
class BulkMessage < ActiveRecord::Base
  include Async
  include Sidekiq::Worker
  
  serialize :results
  belongs_to :person
  belongs_to :organization
  has_many :messages
  
  def do_process
    async(:process)
  end
  
  def process
    bulk_message = BulkMessage.find_by_id(id)
    if bulk_message.present?
      return bulk_message if bulk_message.status == 'completed'
      message = bulk_message.messages.first.message
      bulk_message.update_attributes(status: 'processing')
      with_failure = false
      results = Array.new
      proper = 0
      bulk_message.messages.each do |msg|
        if msg.sent_via == 'sms'
          receiver = PhoneNumber.prettify(msg.to)
          if msg.status != 'sent'
            is_sent = msg.process_message
            proper = 1
            results << {id: msg.id, receiver_name: msg.receiver.name, to: receiver, type: msg.sent_via, is_sent: is_sent}
            with_failure = true unless is_sent
          else
            results << {id: msg.id, receiver_name: msg.receiver.name, to: receiver, type: msg.sent_via, is_sent: msg.status == 'sent'}
          end
        end
      end
      bulk_message.update_attributes(status: 'completed', results: results)
      # raise "(#{proper}) Intentional error for testing: #{with_failure.inspect}"
      PeopleMailer.notify_on_bulk_sms_failure(bulk_message.person, results, bulk_message, message).deliver! if with_failure
      return bulk_message
    end
  end
end
