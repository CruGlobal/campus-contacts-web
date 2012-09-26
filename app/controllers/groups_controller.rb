class GroupsController < ApplicationController
  before_filter :ensure_current_org
  before_filter :get_group
  before_filter :leader_needed, :only => [:create, :new]
  
  def index
    @groups = current_organization.groups.order(params[:q] && params[:q][:s] ? params[:q][:s] : ['name'])
    @q = current_organization.groups.where('1 <> 1').search(params[:q])
    if params[:label].present?
      begin
        @label = current_organization.group_labels.find(params[:label])
        @groups = @groups.where('mh_group_labels.id' => params[:label]).joins(:group_labels)
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Label not found"
      end
    else
      @groups = @groups.includes(:group_labels)
    end
  end

  def show
    @q = Person.where('1 <> 1').search(params[:q])
    @group = Present(@group)

    if params[:q] && params[:q][:s]
      @people = current_organization.non_deleted_people.get_from_group(@group.id).includes(:group_memberships).uniq.order(params[:q][:s])
    else
      @people = current_organization.non_deleted_people.get_from_group(@group.id).includes(:group_memberships).uniq
    end

    authorize! :read, @group
  end

  def edit
    authorize! :edit, @group
  end

  def update
    authorize! :update, @group
    if @group.update_attributes(params[:group])
      redirect_to @group
    else
      redirect_to :back
    end
  end
  
  def new
    index
    @group = current_organization.groups.new
  end

  def create
    @group = current_organization.groups.create(params[:group])
    if @group.valid?
      redirect_to @group
    else
      render :new
    end
  end

  def destroy
    authorize! :destroy, @group
    @group.destroy
    redirect_to groups_path
  end

  protected 
  
    def get_group
      begin
        @group = current_organization.groups.find(params[:id]) if params[:id]
      rescue ActiveRecord::RecordNotFound
        @group = nil
        flash[:error] = "Group not found"
      end
    end
    
    def leader_needed
      authorize! :lead, current_organization
    end
    
end
