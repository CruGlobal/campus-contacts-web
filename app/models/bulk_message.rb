require 'async'
class BulkMessage < ActiveRecord::Base
  include Async
  include Sidekiq::Worker
  sidekiq_options unique: true

  attr_accessible :person_id, :organization_id, :status, :results, :organization

  serialize :results
  belongs_to :person
  belongs_to :organization
  has_many :messages

  def process
    if messages.present?
      return if status == 'completed'
      message = messages.first.message
      update_attributes(status: 'processing')

      batch = Sidekiq::Batch.new
      batch.on(:complete, BulkMessage, 'id' => id, 'message' => message)
      batch.jobs do
        messages.each do |msg|
          Message.perform_async(msg.id)
        end
      end
    else
      update_attributes(status: 'failed', results: nil)
    end
  end

  def on_complete(status, options)
    bulk_message = BulkMessage.find(options['id'])
    bulk_message.update_attributes(status: 'completed', results: status.failure_info)
    PeopleMailer.notify_on_bulk_sms_failure(
      bulk_message.person, status, bulk_message, options['message']
    ).deliver_now if status.failures != 0
  end

  def perform(to_ids, body, organization_id, person_id)
    person = Person.find(person_id)
    organization = Organization.find(organization_id)
    person_ids = []
    body = include_sms_footer(body)
    
    if to_ids.present?
      ids = to_ids.split(',').uniq
      ids.each do |id|
        if id.upcase =~ /GROUP-/
          group = Group.where(id: id.gsub("GROUP-",""), organization_id: organization.id).first
          group.group_memberships.collect{|p| person_ids << p.person_id.to_s } if group.present?
        elsif id.upcase =~ /ROLE-/
          permission = Permission.find(id.gsub("ROLE-",""))
          permission.members_from_permission_org(organization.id).collect{|p| person_ids << p.person_id.to_s } if permission.present?
        elsif id.upcase =~ /LABEL-/
          label = Label.find(id.gsub("LABEL-",""))
          label.label_contacts_from_org(organization).collect{|p| person_ids << p.id.to_s } if label.present?
        elsif id.upcase =~ /ALL-PEOPLE/
          organization.all_people.collect{|p| person_ids << p.id.to_s} if person.user.has_permission?(Permission::ADMIN_ID, organization)
        else
          person_ids << id
        end
      end
    end
    receiver_ids = person_ids.uniq
    if receiver_ids.present?
      bulk_message = person.bulk_messages.create(organization: organization)
      receiver_ids.each do |id|
        person = Person.where(id: id).first
        if person.present? && primary_phone = person.primary_phone_number
          # Do not allow to send text if the phone number is not subscribed
          if organization.is_sms_subscribe?(primary_phone.number)
            # Include sms footer if it can fits to the body
            @message = person.sent_messages.create(
              bulk_message: bulk_message,
              receiver_id: person.id,
              organization_id: organization.id,
              to: person.text_phone_number.number,
              sent_via: 'sms',
              message: body
            )
          end
        end
      end
      bulk_message.process
    end
  end

  def include_sms_footer(body)
    # 140 as the maximum character because we adjusted it for the sms headers
    footer_msg = "\n\n#{I18n.t('people.bulk_sms.sms_footer_message')}"
    total_characters = body.length + footer_msg.length
    body += footer_msg if total_characters <= 140
    body
  end
end
