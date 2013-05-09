class InteractionsController < ApplicationController
  def show_profile
    @person = current_organization.people.where(id: params[:id]).try(:first)
    redirect_to contacts_path unless @person.present?
    @interaction = Interaction.new(created_by_id: current_person.id)
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
end
