class OrganizationalRolesController < ApplicationController
  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status]
    @organizational_role.save
    respond_to do |wants|
      wants.html
      wants.js {render nothing: true}
    end
  end
  
  def move_to
    Organization.transaction do
      from_org = Organization.find(params[:from_id])
      to_org = Organization.find(params[:to_id])
    
      # Remove them from the current org
      ContactAssignment.where(person_id: params[:ids], organization_id: from_org.id).destroy_all
      OrganizationalRole.where(person_id: params[:ids], organization_id: from_org.id, role_id: Role::CONTACT_ID).each do |r|
        OrganizationMembership.where(person_id: r.person_id, organization_id: r.organization_id).first.try(:destroy)
        r.destroy
      end
    
      # Add them to the new org
      params[:ids].each do |id|
        unless OrganizationalRole.where(person_id: id, organization_id: to_org.id).first
          OrganizationMembership.find_or_create_by_person_id_and_organization_id(id, organization_id: to_org.id)
          OrganizationalRole.create(person_id: id, organization_id: to_org.id, role_id: Role::CONTACT_ID)
        end
      end
    end
    render nothing: true
  end
end
