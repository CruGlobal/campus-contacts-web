class Batch # < ActiveRecord::Base
  
  HOURS_INTERVAL = 4
  
  def self.person_transfer
    
    notify_entries = get_unnotified_logs
    
    receiving_orgs = notify_entries.group('new_organization_id')
    receiving_orgs.each do |o|
      organization = Organization.find(o.new_organization_id)
      transferred_contacts = notify_entries.where(new_organization_id: organization.id)
      if organization.admins.count > 0
        organization.admins.each do |admin|
          intro = "As the Admin of #{organization.name} in MissionHub, you have been sent #{transferred_contacts.count} contact#{'s' if transferred_contacts.count > 1}. Please login to missionhub.com as soon as possible to followup the contact#{'s' if transferred_contacts.count > 1}. There may be more information about the contacts in the comment section of their individual profile. If not, you may want to contact the senders at their email address. Below are the contacts sent: <br/><br/>"
          
          if admin.email.present?
            OrganizationMailer.enqueue.notify_person_transfer(admin.email, intro, transferred_contacts)
          end
        end
      end
    end
  end
  
  def self.get_unnotified_logs
    start_time = (Time.now.utc - HOURS_INTERVAL.hour).to_s(:db)
    PersonTransfer.where("TIME(created_at) >= TIME('#{start_time}') AND notified = false")
  end
  
end
