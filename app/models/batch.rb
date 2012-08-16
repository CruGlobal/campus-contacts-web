class Batch # < ActiveRecord::Base
  
  def self.person_transfer_notify
    notify_entries = get_unnotified_transfers
    receiving_orgs = notify_entries.group('new_organization_id')
    
    receiving_orgs.each do |o|
      organization = Organization.find(o.new_organization_id)
      if organization.present?
        transferred_contacts = notify_entries.where(new_organization_id: organization.id).order('old_organization_id')
        admins = organization.all_possible_admins_with_email
        if admins.present?
          admins.each do |admin|
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
                Rails.env.production? ? Airbrake.notify(e) : (raise e)
              end
            end
            intro = I18n.t('batch.person_transfer_message', org_name: organization.name, contacts_count: formated_transferred_contacts.size)
            
            OrganizationMailer.enqueue.notify_person_transfer(admin.email, intro, formated_transferred_contacts)
            # OrganizationMailer.notify_person_transfer(admin.email, intro, formated_transferred_contacts).deliver
            transferred_contacts.update_all(notified: true)
          end
        else
          error = "Root parent organization #{organization.name}(ID#{organization.id}) do not have admin with valid email."
          Rails.env.production? ? Airbrake.notify(error) : (raise error)
        end
      end
    end
  end
  
  def self.new_person_notify
    notify_entries = get_unnotified_new_contacts
    
    receiving_orgs = notify_entries.group('organization_id')
    receiving_orgs.each do |o|
      organization = Organization.find(o.organization_id)
      if organization.present?
        new_contacts = notify_entries.where(organization_id: organization.id).order('organization_id')
        admins = organization.all_possible_admins_with_email
        if admins.present?
          admins.each do |admin|
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
            
            intro = I18n.t('batch.new_person_message', org_name: organization.name, contacts_count: new_contacts.size)
            
            OrganizationMailer.enqueue.notify_new_people(admin.email, intro, formated_new_contacts)
            # OrganizationMailer.notify_new_people(admin.email, intro, formated_new_contacts).deliver
            new_contacts.update_all(notified: true)
          end
        else
          error = "Root parent organization #{organization.name}(ID#{organization.id}) do not have admin with valid email."
          Rails.env.production? ? Airbrake.notify(error) : (raise error)
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
