class GroupMembershipsController < ApplicationController
  def new
    
  end
  
  def create
    
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
end
