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
      people = Person.find(params[:ids])
    
      # Remove them from the current org
      ContactAssignment.where(person_id: params[:ids], organization_id: from_org.id).destroy_all
      people.each do |person|
        from_org.remove_contact(person)
      end
    
      # Add them to the new org
      people.each do |person|
        to_org.add_contact(person)
      end
    end
    render nothing: true
  end
end
