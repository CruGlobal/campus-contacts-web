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
      @error = @organization.errors.full_messages.join('<br />')
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
      @message = t('organizations.add_org_from_crs.conference_is_importing')
      @success = true
    else
      @success = false
      @message = t('organizations.add_org_from_crs.bad_url') unless Ccc::Crs2Conference.get_id_from_url(params[:url])
      @message ||= t('organizations.add_org_from_crs.bad_password')
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
    @date = (Date.today-1).strftime("%Y-%m-%d")
    @date_leaders = (Date.today-91).strftime("%Y-%m-%d")
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
      if params[:tag_as_alumni] == '1'
        alumni_label = Label.find_or_create_by_name_and_organization_id("Alumni", current_organization.id)
        current_organization.add_label_to_person(person, alumni_label.id)
      end
      if params[:tag_as_archived] == '1'
        person.archive_contact_permission(current_organization)
      end
    end
  end

  def archive_contacts
    full_date = params[:archive_contacts_before]
    total_updated = 0

    if full_date.present?
      begin
        date = Date.parse(full_date).strftime("%Y-%m-%d")
      rescue
        msg = "Please enter a valid date format."
      end

      if date.present?
        contacts = current_organization.contacts.where("DATE(`organizational_permissions`.updated_at) <= ?", date)
        if contacts.present?
          contacts.each do |contact|
            archive = contact.archive_contact_permission(current_organization)
            total_updated += 1 if archive
          end
        end
      end
    end
    if msg.present?
      flash[:notice] = msg
    else
      flash[:notice] = t('organizations.cleanup.archive_notice', no: total_updated)
    end

    redirect_to cleanup_organizations_path
  end

  def archive_leaders
    full_date = params[:date_leaders_not_logged_in_after]
    total_updated = 0
    if full_date.present?
      begin
        date = Date.parse(full_date).strftime("%Y-%m-%d")
      rescue
        msg = "Please enter a valid date format."
      end
      if date.present?
        leaders = current_organization.users.find_by_last_login_date_before_date_given(date)
        if leaders.present?
          leaders.each do |leader|
            archive = leader.archive_user_permission(current_organization)
            if archive
              contact_assignments = leader.contact_assignments.where(organization_id: current_organization.id)
              contact_assignments.destroy_all if contact_assignments
              total_updated += 1
            end
          end
        end
      end
    end

    if msg.present?
      flash[:notice] = msg
    else
      flash[:notice] = t('organizations.cleanup.removal_notice', no: total_updated)
    end

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
