class GroupMembershipsController < ApplicationController
  def new
    
  end
  
  def create
    @group = current_organization.groups.find(params[:group_id])
    @person = Person.find(params[:person_id])
    # return access_denied unless has_permission
    @group_membership = @group.group_memberships.find_or_initialize_by_person_id(params[:person_id])
    @group_membership.role = params[:role]
    @group_membership.save
  end
  
  def destroy
    
  end
  
  def search
    if params[:name].present?
      scope = Person.search_by_name(params[:name], current_organization.id)
      @people = scope.includes(:user)
      if params[:show_all].to_s == 'true'
        @total = @people.all.length
      else
        @people = @people.limit(10) 
        @total = scope.count
      end
      render :layout => false
    else
      render :nothing => true
    end
  end
  
  protected
    def has_permission
      return true if @group.leaders.include?(current_person)
      return true if @group.list_publicly? && params[:role] == 'interested' && @person == current_person
      return true if @group.public_signup? && params[:role] == 'member' && @person == current_person
      return false
    end
end
