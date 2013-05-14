class InteractionsController < ApplicationController
  def show_profile
    @person = current_organization.people.where(id: params[:id]).try(:first)
    redirect_to contacts_path unless @person.present?
    @interaction = Interaction.new
    @completed_answer_sheets = @person.completed_answer_sheets(current_organization).where("completed_at IS NOT NULL").order('completed_at DESC')
    if can? :manage, @person
      @interactions = @person.interactions.recent
    end
  end
  
  def change_followup_status
    @person = current_organization.people.where(id: params[:person_id]).try(:first)
    return false unless @person.present?
    @contact_role = @person.contact_role_for_org(current_organization)
    return false unless @contact_role.present?
    
    @contact_role.update_attribute(:followup_status, params[:status])
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
    @people = @people.limit(5)
  end
  
  def search_receivers
    @person = Person.find(params[:person_id])
    @current_person = current_person
    @people = current_organization.people.where("first_name LIKE :key OR last_name LIKE :key", key: "%#{params[:keyword].strip}%")
    @people = @people.where("people.id NOT IN (?)", params[:except].split(',')) if params[:except].present?
    @people = @people.limit(5)
  end
  
  def create
    @interaction = Interaction.new(params[:interaction])
    @interaction.created_by_id = current_person.id
    @interaction.organization_id = current_organization.id
    if @interaction.save
      params[:initiator_id].each do |person_id|
        InteractionInitiator.create(person_id: person_id, interaction_id: @interaction.id)
      end
    end
    show_profile
  end
end
