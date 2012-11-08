class ContactAssignmentsController < ApplicationController
  def create
    @organization = params[:org_id].present? ? Organization.find(params[:org_id]) : current_organization
    org_ids = params[:subs] == 'true' ? @organization.self_and_children_ids : @organization.id
    @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles_including_archived)
    @people_scope = @people_scope.where(id: @people_scope.archived_not_included.collect(&:id)) if params[:include_archived].blank? && params[:archived].blank?
    
    # @keyword = SmsKeyword.find(params[:keyword])
    ContactAssignment.where(person_id: params[:ids], organization_id: @organization.id).destroy_all unless ENV["RAILS_ENV"] == "test"
    if params[:assign_to].present?      
      if params[:assign_to] == "do_not_contact"                
        params[:ids].each do |id|
          om = OrganizationalRole.find_by_person_id_and_organization_id_and_role_id(id, @organization.id, Role::CONTACT_ID)
          Person.find(id).do_not_contact(om.id) if om.present?
        end if params[:ids].present?
        @reload_sidebar = true        
      else            
        @assign_to = Person.find(params[:assign_to])        
        params[:ids].each do |id|
          begin
            ContactAssignment.create!(person_id: id, organization_id: @organization.id, assigned_to_id: @assign_to.id)
          rescue ActiveRecord::RecordNotUnique
            ca = ContactAssignment.find_by_organization_id_and_person_id(@organization.id, id)
            ca.update_attribute(:assigned_to_id, @assign_to.id) if ca
          end
        end if params[:ids].present?
        @reload_sidebar = true
      end
    else
      
    end
    
    # proceed only if we're not bulk assinging contacts to the DNC list 
    if params[:assign_to] != "do_not_contact"
      # if you're assigning this person and their status is DNC, change it back to their prior status or uncontacted      
      OrganizationalRole.where(person_id: params[:ids], organization_id: @organization.id, role_id: Role::CONTACT_ID, followup_status: 'do_not_contact').each do |role|
        role.followup_status = FollowupComment.where(contact_id: role.person_id, organization_id: role.organization_id).where("status <> 'do_not_contact'").order('created_at').last.try(:status) ||
                               'uncontacted'
        role.save!
        @reload_sidebar = true
      end
    end
    unless @reload_sidebar
      render nothing: true
    end
  end
   
   
end
