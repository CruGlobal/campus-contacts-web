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
    @date = Date.today.strftime("%Y-%m-%d")
    
  end
  
  def archive_contacts
    to_archive = current_organization.contacts.find_by_date_created_before_date_given(params[:archive_contacts_before])
    no = to_archive.count
    new_role = Role.find_or_create_by_organization_id_and_name(organization_id: current_organization.id, name: "Archived Contacts Before #{params[:archive_contacts_before]}", i18n: "Archived Contacts Before #{params[:archive_contacts_before]}") unless to_archive.blank?
    to_archive.each do |ta| # destroying contact roles of persons and replacing them with the new created role for archiving
      ta.organizational_roles.where(role_id: Role::CONTACT_ID, organization_id: current_organization.id).first.destroy
      OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id: ta.id, role_id: new_role.id, organization_id: current_organization.id, added_by_id: current_user.person.id)
    end
    
    flash[:notice] = t('organizations.cleanup.archive_notice', no: no)
    redirect_to cleanup_organizations_path
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
