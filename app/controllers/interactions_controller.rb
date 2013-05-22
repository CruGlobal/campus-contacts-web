class InteractionsController < ApplicationController
  def show_profile
    roles_for_assign
    labels_for_assign
    @person = current_organization.people.where(id: params[:id]).try(:first)
    if @person.present?
      @interaction = Interaction.new
      @completed_answer_sheets = @person.completed_answer_sheets(current_organization).where("completed_at IS NOT NULL").order('completed_at DESC')

			@labels = @person.labels_for_org_id(current_organization.id)
			@roles = @person.roles_for_org_id(current_organization.id)
      if can? :manage, @person
        @interactions = @person.filtered_interactions(current_person, current_organization)
        @last_interaction = @interactions.last
        @interactions = @interactions.limited
      
        @all_feeds_page = 1
        @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
        @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
      end
    else
      redirect_to contacts_path
    end
  end
  
  def set_roles
    @person = Person.find(params[:person_id])
    @role_ids = params[:ids].split(',')
    removed_roles = @person.organizational_roles_for_org(current_organization).where("role_id NOT IN (?)", params[:ids])
    removed_roles.delete_all if removed_roles.present?
    @role_ids.each do |role_id|
      role = @person.organizational_roles.find_or_create_by_role_id_and_organization_id(role_id.to_i, current_organization.id)
      role.update_attribute(:added_by_id, current_person.id) if role.added_by_id.nil?
    end
  end
  
  def create_label
    @status = "false"
    if params[:name].present?
      if Label.where("organization_id IN (?) AND LOWER(name) = ?", [current_organization.id,0], params[:name].downcase).present?
        @msg_alert = t('contacts.index.add_label_exists')
      else
        @new_label = Label.create(organization_id: current_organization.id, name: params[:name]) if params[:name].present?
        if @new_label.present?
          @status = "true"
          @msg_alert = t('contacts.index.add_label_success')
        else
          @msg_alert = t('contacts.index.add_label_failed')
        end
      end
    else
      @msg_alert = t('contacts.index.add_label_empty')
    end
  end
  
  def set_labels
    @person = Person.find(params[:person_id])
    @label_ids = params[:ids].split(',')
    removed_labels = @person.organizational_labels_for_org(current_organization).where("label_id NOT IN (?)", params[:ids])
    removed_labels.delete_all if removed_labels.present?
    @label_ids.each do |label_id|
      label = @person.organizational_labels.find_or_create_by_label_id_and_organization_id(label_id.to_i, current_organization.id)
      label.update_attribute(:added_by_id, current_person.id) if label.added_by_id.nil?
    end
		@labels = @person.labels_for_org_id(current_organization.id)
  end
  
  def load_more_all_feeds
    @person = Person.find(params[:person_id])
    if can? :manage, @person
      @all_feeds_page = params[:next_page].to_i
      @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
      @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
    end
  end
  
  def load_more_interactions
    @person = Person.find(params[:person_id])
    if can? :manage, @person
      @interactions = @person.filtered_interactions(current_person, current_organization).where("id < ?",params[:last_id])
      @last_interaction = @interactions.last
      @interactions = @interactions.limited
    end
  end
  
  def change_followup_status
    @person = current_organization.people.where(id: params[:person_id]).try(:first)
    return false unless @person.present?
    @new_status = params[:status]
    @contact_role = @person.contact_role_for_org(current_organization)
    return false unless @contact_role.present?
    
    @contact_role.update_attribute(:followup_status, @new_status)
  end
  
  def reset_edit_form
    @person = current_organization.people.where(id: params[:person_id]).try(:first)
  end
  
  def show_new_interaction_form
    @person = Person.find(params[:person_id])
    @interaction = Interaction.new
  end
  
  def show_edit_interaction_form
    @person = Person.find(params[:person_id])
    @interaction = Interaction.find(params[:id])
  end
  
  def search_initiators
    @person = Person.find(params[:person_id])
    @current_person = current_person
    @people = current_organization.people.where("first_name LIKE :key OR last_name LIKE :key", key: "%#{params[:keyword].strip}%")
    @people = @people.where("people.id NOT IN (?)", params[:except].split(',')) if params[:except].present?
    # @people = @people.limit(5)
  end
  
  def search_receivers
    @person = Person.find(params[:person_id])
    @current_person = current_person
    @people = current_organization.people.where("first_name LIKE :key OR last_name LIKE :key", key: "%#{params[:keyword].strip}%")
    @people = @people.where("people.id NOT IN (?)", params[:except].split(',')) if params[:except].present?
    # @people = @people.limit(5)
  end
  
  def create
    @person = Person.find(params[:person_id])
    @interaction = Interaction.new(params[:interaction])
    @interaction.created_by_id = current_person.id
    @interaction.organization_id = current_organization.id
    if @interaction.save
      params[:initiator_id].each do |person_id|
        @interaction.interaction_initiators.find_or_create_by_person_id(person_id.to_i)
      end
    end
  end
  
  def update
    @person = Person.find(params[:person_id])
    @interaction = Interaction.find(params[:interaction_id])
    @interaction.update_attributes(params[:interaction])
    params[:initiator_id].uniq.each do |person_id|
      @interaction.interaction_initiators.find_or_create_by_person_id(person_id.to_i)
    end
    # delete removed
    removed_initiators = @interaction.interaction_initiators.where("person_id NOT IN (?)",params[:initiator_id])
    removed_initiators.delete_all if removed_initiators.present?
    # delete duplicates
    interaction_initiator_ids = @interaction.interaction_initiators.group("person_id").collect(&:id)
    duplicate_initiators = @interaction.interaction_initiators.where("id NOT IN (?)",interaction_initiator_ids)
    duplicate_initiators.delete_all if duplicate_initiators.present?
  end
end
