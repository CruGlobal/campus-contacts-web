class OrganizationsController < ApplicationController
  respond_to :html, :js
  before_filter :get_organization, :only => [:show, :edit, :update, :destroy]
  
  def index
    
  end
  
  def show
    respond_with @organization
  end
  
  def edit
    respond_with @organization
  end
  
  def update
    if @organization.update_attributes(params[:organization])
      respond_to do |wants|
        wants.html { redirect_to organizations_path }
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
  
  def thanks
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
      @organization.add_admin(current_person) unless @organization.parent && @organization.parent.show_sub_orgs?
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
  
  def settings
    @show_year_in_school = current_organization.settings[:show_year_in_school] ||= false
  end
  
  def update_settings
    org = current_organization
    org.settings[:show_year_in_school] = params[:show_year_in_school] == "on" ? true : false
    if org.save
      flash[:notice] = "Successfully updated org settings!"
    else
      flash[:error] = "An error occurred when trying to update org settings"
    end

    redirect_to '/organizations/settings'
  end
  
  protected
    def get_organization
      @organization = Organization.subtree_of(current_organization.root_id).find(params[:id])
      authorize! :manage, @organization
    end
end
