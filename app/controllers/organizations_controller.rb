class OrganizationsController < ApplicationController
  respond_to :html, :js
  before_filter :get_organization, :only => [:show, :edit, :update, :destroy]
  
  def show
    respond_with @organization
  end
  
  def edit
    respond_with @organization
  end
  
  def update
    if @organization.update_attributes(params[:organization])
      respond_to do |wants|
        wants.html { organizations_path }
      end
    else
      respond_to do |wants|
        wants.html { render :edit }
      end
    end
  end
  
  def new
    @organization = Organization.new(person_id: current_person.id)
    render layout: 'splash'
  end
  
  def signup
    @organization = Organization.new(params[:organization])
    if @organization.save
      redirect_to thanks_organizations_path
    else
      render :new, layout: 'splash'
    end
  end
  
  def create
    @parent = Organization.find(params[:organization][:parent_id])
    authorize! :manage, @parent
    @organization = Organization.create(params[:organization]) # @parent.children breaks for some reason
    if @organization.new_record?
      render 'add_org' and return
    else
      @organization.add_admin(current_person)
    end
  end
  
  def destroy
    @organization.destroy
    redirect_to organizations_path
  end
  
  def search
    scope = Organization.subtree_of(current_organization.root_id).where("name like ?", "%#{params[:q]}%")
    @organizations = scope.order('name').limit(20)
    @total = scope.count
    respond_with @organizations
  end
  
  protected
    def get_organization
      @organization = Organization.subtree_of(current_organization.root_id).find(params[:id])
      authorize! :manage, @organization
    end
end
