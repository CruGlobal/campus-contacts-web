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
end
