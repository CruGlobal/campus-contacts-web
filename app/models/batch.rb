class Batch # < ActiveRecord::Base
  
  def self.person_transfer_notify
    
    queued_email = 0
    no_admin = 0
    notify_entries = get_unnotified_transfers
    receiving_orgs = notify_entries.group('new_organization_id')
    receiving_orgs.each do |o|
      organization = Organization.find(o.new_organization_id)
      if organization.present?
        transferred_contacts = notify_entries.where(new_organization_id: organization.id).order('old_organization_id')
        if organization.admins.count > 0
          organization.admins.each do |admin|
            if admin.email.present?
              formated_transferred_contacts = Array.new
              transferred_contacts.each do |contact|
                begin
                  if contact.present? && contact.person.present? && contact.transferred_by.present? && contact.old_organization.present?
                    transfer_log = Hash.new
                    transfer_log['transferer_name'] = contact.transferred_by.name
                    transfer_log['transferer_email'] = contact.transferred_by.email
                    transfer_log['old_org_name'] = contact.old_organization.name
                    transfer_log['contact_name'] = contact.person.name
                    transfer_log['contact_email'] = contact.person.email
                    formated_transferred_contacts << transfer_log
                  end
                rescue => e
                  # something wrong with that person (probably missing)
                  Rails.env.production? ? Airbrake.notify(e) : (raise e)
                end
              end
              intro = "As the Admin of #{organization.name} in <a href='https://www.missionhub.com' target='_blank'>MissionHub</a>, you have been sent #{formated_transferred_contacts.size} contact#{'s' if formated_transferred_contacts.size > 1}. Please login to missionhub.com as soon as possible to followup the contact#{'s' if formated_transferred_contacts.size > 1}. There may be more information about the contacts in the comment section of their individual profile. If not, you may want to contact the senders at their email address. Below are the contacts sent:"
    
              OrganizationMailer.enqueue.notify_person_transfer(admin.email, intro, formated_transferred_contacts)
              transferred_contacts.update_all(notified: true)
              queued_email += 1
            end
          end
        else
          no_admin += 1
        end
      end
    end
  end
  
  def self.new_person_notify
    
    queued_email = 0
    no_admin = 0
    notify_entries = get_unnotified_new_contacts
    
    receiving_orgs = notify_entries.group('organization_id')
    receiving_orgs.each do |o|
      organization = Organization.find(o.organization_id)
      if organization.present?
        new_contacts = notify_entries.where(organization_id: organization.id).order('organization_id')
        if organization.admins.count > 0
          organization.admins.each do |admin|
          
            if admin.email.present?
              formated_new_contacts = Array.new
              new_contacts.each do |new_person|
                begin
                  if new_person.present? && new_person.person.present?
                    new_contact_log = Hash.new
                    new_contact_log['person_name'] = new_person.person.name
                    new_contact_log['person_email'] = new_person.person.email
                    formated_new_contacts << new_contact_log
                  end
                rescue => e
                  # something wrong with that person (probably missing)
                  Rails.env.production? ? Airbrake.notify(e) : (raise e)
                end
              end
              intro = "As the Admin of #{organization.name} in <a href='https://www.missionhub.com' target='_blank'>MissionHub</a>, there are #{formated_new_contacts.size} new contact#{'s' if formated_new_contacts.size > 1} in your organization. Please login to missionhub.com as soon as possible to followup the contact#{'s' if formated_new_contacts.size > 1}. Below is the list of new contacts:"
            
              OrganizationMailer.enqueue.notify_new_people(admin.email, intro, formated_new_contacts)
              new_contacts.update_all(notified: true)
              queued_email += 1
            end
          end
        else
          no_admin += 1
        end
      end
    end
  end
  
  def self.get_unnotified_transfers
    PersonTransfer.where(notified: false)
  end
  
  def self.get_unnotified_new_contacts
    NewPerson.where(notified: false)
  end
  
end
