class OrganizationalLabelsController < ApplicationController

  def update_all
    label_ids = params[:labels]
    person = Person.find(params[:id])
    if label_ids.present?
      label_ids.each do |label_id|
        if label_id.present?
          org_label = OrganizationalLabel.find_or_create_by_person_id_and_organization_id_and_label_id(person.id, current_organization.id, label_id)
          org_label.update_attributes({removed_date: nil, added_by_id: current_user.person.id})
        end
      end
    else
      # We don't want to remove all of a person's labels using this method.
    end
    @new_label_set = (person.assigned_organizational_labels(current_organization.id).default_labels + person.assigned_organizational_labels(current_organization.id).non_default_labels).collect(&:name)
  end
end
