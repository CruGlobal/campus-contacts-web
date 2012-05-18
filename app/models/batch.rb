class Batch # < ActiveRecord::Base
  
  def self.person_transfer
    
    queued_email = 0
    notify_entries = get_unnotified_logs
    
    receiving_orgs = notify_entries.group('new_organization_id')
    receiving_orgs.each do |o|
      organization = Organization.find(o.new_organization_id)
      transferred_contacts = notify_entries.where(new_organization_id: organization.id).order('old_organization_id')
      if organization.admins.count > 0
        organization.admins.each do |admin|
          intro = "As the Admin of #{organization.name} in <a href='https://www.missionhub.com' target='_blank'>MissionHub</a>, you have been sent #{transferred_contacts.count} contact#{'s' if transferred_contacts.count > 1}. Please login to missionhub.com as soon as possible to followup the contact#{'s' if transferred_contacts.count > 1}. There may be more information about the contacts in the comment section of their individual profile. If not, you may want to contact the senders at their email address. Below are the contacts sent:"
          
          if admin.email.present?
            OrganizationMailer.enqueue.notify_person_transfer(admin.email, intro, transferred_contacts)
            # OrganizationMailer.notify_person_transfer(admin.email, intro, transferred_contacts).deliver
            transferred_contacts.update_all(notified: true)
            queued_email += 1
          end
        end
      end
    end
    puts "#{queued_email} Contacts Transfer Notification email(s) queued."
  end
  
  def self.get_unnotified_logs
    PersonTransfer.where(notified: false)
  end
  
end