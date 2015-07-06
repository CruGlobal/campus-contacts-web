class BulkMessagesController < ApplicationController
  before_filter :ensure_current_org

  def sms
    authorize! :lead, current_organization
    to_ids = params[:to]

		person_ids = []
		if to_ids.present?
			ids = to_ids.split(',').uniq
			ids.each do |id|
				if id.upcase =~ /GROUP-/
					group = Group.where(id: id.gsub("GROUP-",""), organization_id: current_organization.id).first
					group.group_memberships.collect{|p| person_ids << p.person_id.to_s } if group.present?
				elsif id.upcase =~ /ROLE-/
					permission = Permission.find(id.gsub("ROLE-",""))
					permission.members_from_permission_org(current_organization.id).collect{|p| person_ids << p.person_id.to_s } if permission.present?
        elsif id.upcase =~ /LABEL-/
					label = Label.find(id.gsub("LABEL-",""))
					label.label_contacts_from_org(current_organization).collect{|p| person_ids << p.id.to_s } if label.present?
				elsif id.upcase =~ /ALL-PEOPLE/
					current_organization.all_people.collect{|p| person_ids << p.id.to_s} if is_admin?
				else
					person_ids << id
				end
			end
		end
    receiver_ids = person_ids.uniq
    if receiver_ids.present?
      bulk_message = current_person.bulk_messages.create(organization: current_organization)
      receiver_ids.each do |id|
      	person = Person.where(id: id).first
        if person.present? && primary_phone = person.primary_phone_number
          # Do not allow to send text if the phone number is not subscribed
          if is_subscribe = current_organization.is_sms_subscribe?(primary_phone.number)
            # Include sms footer if it can fits to the body
            body = include_sms_footer(params[:body])
            @message = current_person.sent_messages.create(
              bulk_message: bulk_message,
              receiver_id: person.id,
              organization_id: current_organization.id,
              to: person.text_phone_number.number,
              sent_via: 'sms',
              message: body
            )
          end
        end
      end
      bulk_message.do_process
    end
    render :nothing => true
  end
end
