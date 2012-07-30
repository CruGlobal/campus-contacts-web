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
    @show_year_in_school = current_organization.settings[:show_year_in_school]
  end
  
  def cleanup
    @date = (Date.today-1).strftime("%m-%d-%Y")
    @date_leaders = (Date.today-91).strftime("%m-%d-%Y")
    
  end
  
  def archive_contacts
    a = params[:archive_contacts_before].split('-')
    a[0], a[1] = a[1], a[0]
    a = a.join('-')
    a = (a.to_date+1).strftime("%Y-%m-%d")
    to_archive = current_organization.contacts.find_by_date_created_before_date_given(a)
    no = 0
    to_archive.each do |ta| # destroying contact roles of persons and replacing them with the new created role for archiving
      ta.archive_contact_role(current_organization)
      no+=1 if ta.is_archived?(current_organization)
    end
    flash[:notice] = t('organizations.cleanup.archive_notice', no: no)
    #redirect_to cleanup_organizations_path
    if to_archive.blank?
      redirect_to cleanup_organizations_path
    else
      redirect_to people_path+"?archived=true&include_archived=true"
    end
  end
  
  def remove_leaders
    a = params[:date_leaders_not_logged_in_after].split('-')
    a[0], a[1] = a[1], a[0]
    a = a.join('-')
    a = (a.to_date+1).strftime("%Y-%m-%d")
    to_remove = current_organization.only_leaders.find_by_last_login_date_before_date_given(a)
    no = to_remove.count
    to_remove.each do |ta| # destroying leader roles of persons
      #ta.organizational_roles.where(role_id: Role::LEADER_ID, organization_id: current_organization.id).first.destroy
      ta.archive_leader_role(current_organization)
      ca = ta.contact_assignments.where(organization_id: current_organization.id).all
      ca.collect(&:destroy)
    end
    flash[:notice] = t('organizations.cleanup.removal_notice', no: no)
    #redirect_to cleanup_organizations_path
    person_ids = to_remove.collect{ |l| l.personID }
    if to_remove.blank?
      redirect_to cleanup_organizations_path
    else
      redirect_to people_path+"?custom=1&ids=#{person_ids.join(',')}"
    end
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
