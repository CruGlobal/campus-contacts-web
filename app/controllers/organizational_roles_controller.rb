class OrganizationalRolesController < ApplicationController
  def update
    @organizational_role = OrganizationalRole.find(params[:id])
    @organizational_role.followup_status = params[:status]
    if params[:status] == 'do_not_contact'
      ContactAssignment.where(person_id: @organizational_role.person_id, organization_id: @organizational_role.organization_id).destroy_all
    end
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
      keep_contact = params[:keep_contact]
      
      unless from_org == to_org
        people = Person.find(params[:ids])

        people.each do |person|
          from_org.move_contact(person, to_org, keep_contact, current_person)
        end
      end
    end
    render nothing: true
  end
end
