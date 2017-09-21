class Batch
  def self.new_person_notify
    notify_entries = get_unnotified_new_contacts

    receiving_orgs = notify_entries.group('organization_id')
    receiving_orgs.each do |o|
      if Organization.exists?(o.organization_id)
        organization = Organization.find(o.organization_id)
        new_contacts = notify_entries.where(organization_id: organization.id).order('organization_id')
        admins = organization.all_possible_admins_with_email
        if admins.present?
          admins.each do |admin|
            formated_new_contacts = []
            new_contacts.each do |new_person|
              begin
                if new_person.present? && new_person.person.present?
                  new_contact_log = {}
                  new_contact_log['person_name'] = new_person.person.name
                  new_contact_log['person_email'] = new_person.person.email
                  formated_new_contacts << new_contact_log
                end
              rescue => e
                # something wrong with that person (probably missing)
                Rails.env.production? ? Rollbar.error(e) : (raise e)
              end
            end

            intro = I18n.t('batch.new_person_message', org_name: organization.name, contacts_count: new_contacts.size)
            OrganizationMailer.notify_new_people(admin.email, intro, formated_new_contacts).deliver_now
            new_contacts.update_all(notified: true)
          end
        else
          error = "Root parent organization #{organization.name}(ID#{organization.id}) do not have admin with valid email."
          if Rails.env.production?
            Rollbar.error(
              error_class: 'Batch::NewPersonNotify',
              error_message: "Batch::NewPersonNotify: #{error}",
              parameters: { receiving_organizations: receiving_orgs.collect(&:organization_id) }
            )
          else
            fail error
          end
        end
      end
    end
  end

  def self.get_unnotified_new_contacts
    NewPerson.where(notified: false)
  end
end
