class GroupsController < ApplicationController
  before_filter :ensure_current_org
  before_filter :get_group
  before_filter :leader_needed, :only => [:create, :new]

  def index
    if params[:search].present? && params[:search][:meta_sort].present?
      sort_query = params[:search][:meta_sort].gsub('.',' ')
    	if ['name'].any?{ |i| sort_query.include?(i) }
  			order_query = sort_query.gsub('name','groups.name')
  		end
    else
      order_query = "groups.name"
    end

    @groups = current_organization.groups.order(order_query)
    @q = current_organization.groups.where('1 <> 1').search(params[:search])

    if params[:label].present?
      begin
        @label = current_organization.group_labels.find(params[:label])
        @groups = @groups.where('group_labels.id' => params[:label]).joins(:group_labels)
      rescue ActiveRecord::RecordNotFound
        flash[:error] = "Label not found"
      end
    else
      @groups = @groups.includes(:group_labels)
    end

    people_ids = GroupMembership.where(group_id: @groups.collect(&:id)).collect(&:person_id)
    @people = current_organization.people.where(id: people_ids)
    @all_people_with_phone_number = @people.includes(:primary_phone_number).where('phone_numbers.number is not NULL').uniq
    @all_people_with_email = @people.where(id: people_ids).includes(:primary_email_address).where('email_addresses.email is not NULL').uniq
  end

  def show
    permissions_for_assign

    @group = Present(@group)
    @people = current_organization.people.get_from_group(@group.id).uniq

    if params[:search].present? && params[:search][:meta_sort].present?
      sort_query = params[:search][:meta_sort].gsub('.',' ')
      @people = @people.includes(:group_memberships) if sort_query.include?('permission')
			order_string = sort_query.gsub('first_name','people.first_name')
                               .gsub('permission','group_memberships.permission')
    else
      order_string = "people.first_name"
    end

    @q = @people.where('1 <> 1').search(params[:search])
    @people = @people.order(order_string)
    @all_people_with_phone_number = @people.includes(:primary_phone_number).where('phone_numbers.number is not NULL')
    @all_people_with_email = @people.includes(:primary_email_address).where('email_addresses.email is not NULL')

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
