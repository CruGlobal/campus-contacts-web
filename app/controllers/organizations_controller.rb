class OrganizationsController < ApplicationController
  respond_to :html, :js
  before_filter :get_organization, :only => [:show, :edit, :update, :destroy, :update_from_crs]

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
    unless can?(:manage, @parent) || can?(:manage, @parent.parent) || can?(:manage, @parent.root)
      raise CanCan::AccessDenied
    end
    @organization = Organization.create(params[:organization]) # @parent.children breaks for some reason
    if @organization.new_record?
      render 'add_org' and return
    else
      @organization.add_admin(current_person) unless @organization.parent && @organization.parent.show_sub_orgs?
    end
  end

  def create_from_crs
    authorize! :manage, current_organization
    @organization = current_organization.children.new(terminology: 'Conference')

    if conference = Ccc::Crs2Conference.find_from_url_and_password(params[:url], params[:admin_password])
      # See if we already have a sub-org for this conference
      if previous = current_organization.children.where(conference_id: conference.id).first
        @organization = previous
      else
        @organization.conference_id = conference.id
        @organization.name = conference.name
        @organization.save!
      end
      @organization.queue_import_from_conference(current_user)
      flash[:notice] = t('organizations.add_org_from_crs.conference_is_importing')
      render and return
    else
      error = t('organizations.add_org_from_crs.bad_url') unless Ccc::Crs2Conference.get_id_from_url(params[:url])
      error ||= t('organizations.add_org_from_crs.bad_password')
      flash.now[:error] = error
      render action: 'add_org_from_crs'
    end
  end

  def update_from_crs
    @organization.queue_import_from_conference(current_user)
    flash[:notice] = t('organizations.add_org_from_crs.conference_is_importing')
    redirect_to :back
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

  def available_for_transfer
    @available = Array.new
    sent_people = current_organization.sent
    if sent_people.present?
      @people = current_organization.contacts.where("(people.first_name LIKE :name OR people.last_name LIKE :name) AND people.id NOT IN (:people_ids)", name: "%#{params[:term]}%", people_ids: sent_people.collect(&:id))
    else
      @people = current_organization.contacts.where("(people.first_name LIKE :name OR people.last_name LIKE :name)", name: "%#{params[:term]}%")
    end

    @people.each do |person|
      @available << {label: person.to_s, id: person.id}
    end
    render json: @available.to_json
  end

  def queue_transfer
    @person = Person.find(params[:person_id])
    if @person.present?
      @person.queue_for_transfer(current_organization.id, current_person.id)
    end
  end

  def transfer
    @pending_transfer = current_organization.pending_transfer
  end

  def do_transfer
    @people = Person.where(id: params[:ids])
    @sent_team_org = Organization.find(472) # CM 100% Sent Team
    @people.each do |person|
      @sent_team_org.add_contact(person)
      sent_record = person.set_as_sent
      sent_record.update_attribute('transferred_by_id', current_person.id)
      current_organization.add_label_to_person(person, Label::ALUMNI_ID) if params[:tag_as_alumni] == '1'
      if params[:tag_as_archived] == '1'
        person.archive_contact_permission(current_organization)
      end
    end
  end

  def archive_contacts
    a = params[:archive_contacts_before].split('-')
    a[0], a[1] = a[1], a[0]
    a = a.join('-')
    a = (a.to_date+1).strftime("%Y-%m-%d")
    to_archive = current_organization.contacts.find_by_date_created_before_date_given(a)
    no = 0
    to_archive.each do |ta| # destroying contact permissions of persons and replacing them with the new created permission for archiving
      ta.archive_contact_permission(current_organization)
      no+=1 if ta.is_archived?(current_organization)
    end
    flash[:notice] = t('organizations.cleanup.archive_notice', no: no)
    #redirect_to cleanup_organizations_path
    if no == 0
      redirect_to cleanup_organizations_path
    else
      redirect_to people_path+"?archived=true&include_archived=true"
    end
  end

  def archive_leaders
    if params[:date_leaders_not_logged_in_after].present?
      date_given = (Date.strptime(params[:date_leaders_not_logged_in_after], "%m-%d-%Y") + 1.day).strftime('%Y-%m-%d')
      leaders = current_organization.only_users.find_by_last_login_date_before_date_given(date_given)
      leaders_count = leaders.count

      leaders.each do |leader|
        leader.archive_user_permission(current_organization)
        assignments = leader.contact_assignments.where(organization_id: current_organization.id).all
        assignments.collect(&:destroy)
      end

      flash[:notice] = t('organizations.cleanup.removal_notice', no: leaders_count)
      person_ids = leaders.collect(&:id)
    end

    if leaders.blank?
      redirect_to cleanup_organizations_path
    else
      redirect_to people_path+"?archived=true&include_archived=true"
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

  def api

  end

  def generate_api_secret
    current_organization.generate_api_secret

    redirect_to api_organizations_path
  end

  protected
  def get_organization
    if params[:id]
      @organization = Organization.find(params[:id])
    else
      @organization = Organization.subtree_of(current_organization.root_id).first
    end
    unless can?(:manage, @organization) || can?(:manage, @organization.parent) || can?(:manage, @organization.root)
      raise CanCan::AccessDenied
    end
  end
end
