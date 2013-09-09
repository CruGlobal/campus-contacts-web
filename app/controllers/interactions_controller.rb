class InteractionsController < ApplicationController
  before_filter :authorize

  def show_profile
    permissions_for_assign
    groups_for_assign
    labels_for_assign

    @person = current_person.id == params[:id].to_i ? current_person : current_organization.people.where(id: params[:id]).first
    if @person.present?
      # Ensure single permission
      @person.ensure_single_permission_for_org_id(current_organization.id)
      @interaction = Interaction.new
      @completed_answer_sheets = @person.completed_answer_sheets(current_organization).order('completed_at DESC')

			@labels = @person.assigned_organizational_labels(current_organization.id).uniq
			@permission = @person.assigned_organizational_permissions(current_organization.id).first
      @groups = @person.groups_for_org_id(current_organization.id)
      @assigned_tos = @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id)
      @friends = @person.friends_in_orgnization(current_organization)
      if can? :manage, @person
        @interactions = @person.filtered_interactions(current_person, current_organization)
        @last_interaction = @interactions.last
        @interactions = @interactions.limited

        @all_feeds_page = 1
        @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
        @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
      end
    else
      redirect_to all_contacts_path
    end
  end

  def search_leaders
    @person = Person.find(params[:person_id])
    @current_person = current_person
    @people = current_organization.leaders.where("first_name LIKE :key OR last_name LIKE :key", key: "%#{params[:keyword].strip}%")
    @people = @people.where("people.id NOT IN (?)", params[:except].split(',')) if params[:except].present?
  end

  def set_groups
    @person = Person.find(params[:person_id])
    @group_ids = params[:ids].split(',')

    if @group_ids.present?
      removed_groups = @person.group_memberships_for_org(current_organization).where("group_id NOT IN (?)", @group_ids)
      removed_groups.delete_all if removed_groups.present?
    else
      @person.group_memberships_for_org(current_organization).delete_all
    end

    @group_ids.each do |group_id|
      group = @person.group_memberships.find_or_create_by_group_id(group_id.to_i)
      group.update_attribute(:role, 'member') if group.role.nil?
    end
    @groups = @person.groups_for_org_id(current_organization.id)
  end

  def set_permissions
    @people = Person.where(id: params[:people_ids].split(','))
    @permission_id = params[:permission_id]

    @people.each do |person|
      current_organization.change_person_permission(person, @permission_id, current_person.id)
      @permissions = person.permissions_for_org_id(current_organization.id)
      @assigned_tos = person.assigned_tos.where("contact_assignments.organization_id" => current_organization.id)
    end

    if @people.count == 1
      @person = @people.first
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
    @people = Person.where(id: params[:people_ids].split(','))
    @label_ids = params[:label_ids].split(',')
    @remove_label_ids = params[:remove_label_ids].split(',')

    @people.each do |person|
      @label_ids.each do |label_id|
        label = person.organizational_labels.find_or_create_by_label_id_and_organization_id(label_id.to_i, current_organization.id)
        label.update_attribute(:added_by_id, current_person.id) if label.added_by_id.nil?
      end
      removed_labels = person.organizational_labels_for_org(current_organization).where("label_id IN (?)", @remove_label_ids)
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

  def load_more_all_feeds
    @person = Person.find(params[:person_id])
    @all_feeds_page = params[:next_page].to_i
    @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
    @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
    @all_feeds_page += 1
  end

  def load_more_interactions
    @person = Person.find(params[:person_id])
    if can? :manage, @person
      @interactions = @person.filtered_interactions(current_person, current_organization).where("interactions.id < ?",params[:last_id])
      @last_interaction = @interactions.last
      @interactions = @interactions.limited
    end
  end

  def change_followup_status
    @person = current_organization.people.where(id: params[:person_id]).try(:first)
    return false unless @person.present?
    @new_status = params[:status]
    @contact_permission = @person.contact_permission_for_org(current_organization)
    @contact_permission.update_attribute(:followup_status, @new_status) if @contact_permission.present?
  end

  def reset_edit_form
    @person = current_organization.people.find(params[:person_id])
    if @person.present?
      @assigned_tos = @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id)
    end
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
    @interaction.updated_by_id = current_person.id
    if @interaction.save
      @success = true
      @interaction.set_initiators(params[:initiator_id])
    end
    @all_feeds_page = 1
    @all_feeds = @person.all_feeds(current_person, current_organization, @all_feeds_page)
    @last_all_feeds = @person.all_feeds_last(current_person, current_organization)
  end

  def update
    @person = Person.find(params[:person_id])
    @interaction = Interaction.find(params[:interaction_id])
    @interaction.update_attributes(params[:interaction])
    @interaction.update_attribute(:updated_by_id, current_person.id)
    @interaction.set_initiators(params[:initiator_id])
    @assigned_tos = @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id)
  end

  def destroy
    @interaction = current_organization.interactions.find(params[:id])
    @person = @interaction.receiver
    @interaction.destroy
  end

  protected
  def authorize
    authorize! :manage_contacts, current_organization
  end

end
