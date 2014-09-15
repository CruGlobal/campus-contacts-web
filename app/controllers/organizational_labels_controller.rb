class OrganizationalLabelsController < ApplicationController
  before_filter :authorize
  skip_before_filter :clear_advanced_search

  def set_labels
    @people = Person.where(id: params[:people_ids].split(','))
    @label_ids = params[:label_ids].split(',')
    @remove_label_ids = params[:remove_label_ids].split(',')
    @unchanged_label_ids = params[:unchanged_label_ids].split(',')

    @people.each do |person|
      @label_ids.each do |label_id|
        label = person.organizational_labels.find_or_create_by_label_id_and_organization_id(label_id.to_i, current_organization.id)
        label.update_attribute(:added_by_id, current_person.id) if label.added_by_id.nil?
      end
      removed_labels = person.organizational_labels_for_org(current_organization).where("label_id IN (?)", @remove_label_ids - @unchanged_label_ids)
      removed_labels.delete_all if removed_labels.present?
    end

    if @people.count == 1
      @person = @people.first
      @labels = @person.assigned_organizational_labels(current_organization.id).uniq
      @all_feeds_page = 1
      @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
      @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
    end
  end

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


  protected
  def authorize
    authorize! :manage_contacts, current_organization
  end
end
