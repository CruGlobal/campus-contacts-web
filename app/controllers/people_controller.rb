require 'csv'
class PeopleController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize_merge, only: [:merge, :confirm_merge, :do_merge, :merge_preview]
  before_filter :authorize_merge
  # GET /people
  # GET /people.xml
  def index
    authorize! :read, Person
    fetch_people
  
    @roles = current_organization.roles

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.xml  { render xml: @people }
    # end
  end
  
  def export
    index
    out = ""
    CSV.generate(out) do |rows|
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('people.index.gender'), t('people.index.email'), t('people.index.phone'), t('people.index.year_in_school')]
      @all_people.each do |person|
        rows << [person.firstName, person.lastName, person.gender, person.email, person.pretty_phone_number, person.yearInSchool]
      end
    end
    filename = current_organization.to_s
    filename += " - #{Role.find_by_id(params[:role_id]).to_s.pluralize}" if params[:role_id].present?
    send_data(out, :filename => "#{filename}.csv", :type => 'application/csv' )
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    @person = current_organization.people.find(params[:id])
    authorize! :read, @person

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @person }
    end
  end

  # GET /people/new
  # GET /people/new.xml
  # def new
  #   authorize! :create, Person
  #   @person = Person.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.xml  { render xml: @person }
  #   end
  # end

  # GET /people/1/edit
  def edit
    @person = current_organization.people.find(params[:id])
    authorize! :edit, @person
  end
  
  def search_ids
    @people = Person.search_by_name(params[:q])
    respond_to do |wants|
      wants.json { render text: @people.collect(&:id).to_json }
    end
  end
  
  def merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact
  end
  
  def confirm_merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact
    unless @people.length >= 2
      redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "You must select at least 2 people to merge"
      return false
    end
    @keep = @people.delete_at(params[:keep].to_i)
    unless @keep
      redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "You must specify which person to keep"
      return false
    end
    # If any of the other people have users, the keeper has to have a user
    unless @keep.user
      if person = @people.detect(&:user)
        redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "Person ID# #{person.id} has a user record, but the person you are trying to keep doesn't. You should keep the record with a user."
        return false
      end
    end
        
  end
  
  def merge_preview
    render nothing and return false unless params[:id].to_i > 0
    @person = Person.find_by_personID(params[:id])
    respond_to do |wants|
      wants.js {  }
    end
  end
  
  def do_merge
    @keep = Person.find(params[:keep_id])
    params[:merge_ids].each do |id|
      person = Person.find(id)
      if @keep.user && person.user
        @keep.user.merge(person.user)
      else
        @keep.merge(person)
      end
    end
    redirect_to merge_people_path, notice: "You've just merged #{params[:merge_ids].length + 1} people"
  end

  def create
    authorize! :create, Person
    Person.transaction do
      params[:person] ||= {}
      params[:person][:email_address] ||= {}
      params[:person][:phone_number] ||= {}
      unless params[:person][:firstName].present?# && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
        render :nothing => true and return
      end
      @person, @email, @phone = create_person(params[:person])
      
      if @person.save
        
        if params[:roles].present?
          role_ids = params[:roles].keys.map(&:to_i)
          params[:roles].keys.each do |role_id|
            @person.organizational_roles.create(role_id: role_id, organization_id: current_organization.id)
          end

          # we need a valid email address to make a leader
          if role_ids.include?(Role::LEADER_ID) || role_ids.include?(Role::ADMIN_ID)
            @new_person = @person.create_user! if @email.present? # create a user account if we have an email address
            if @new_person && @new_person.save
              @person = @new_person
              current_organization.notify_new_leader(@person, current_person) 
            else
              @person.reload
              @email = @person.primary_email_address || @person.email_addresses.new
              @phone = @person.primary_phone_number || @person.phone_numbers.new
              render 'add_person' and return
            end
          end
        else
          current_organization.add_involved(@person)
        end
        
        respond_to do |wants|
          wants.html { redirect_to :back }
          wants.mobile { redirect_to :back }
          wants.js 
        end
      else
        flash.now[:error] = ''
        flash.now[:error] += 'First name is required.<br />' unless @person.firstName.present?
        flash.now[:error] += 'Phone number is not valid.<br />' if @phone && !@phone.valid?
        flash.now[:error] += 'Email address is not valid.<br />' unless @email && @email.valid?
        render 'add_person'
        return
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = current_organization.people.find(params[:id])
    authorize! :edit, @person
  
    respond_to do |format|
      if @person.update_attributes(params[:person])
        format.html { redirect_to(@person, notice: 'Person was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def bulk_delete
    authorize! :manage, current_organization
    ids = params[:ids].to_s.split(',')
    if ids.present?
      current_organization.organization_memberships.where(:person_id => ids).destroy_all
      current_organization.organizational_roles.where(:person_id => ids).destroy_all
    end
    render nothing: true
  end
  # 
  # # DELETE /people/1
  # # DELETE /people/1.xml
  def destroy
    @person = Person.find(params[:id])
    # @person.destroy
  
    respond_to do |format|
      format.html { redirect_to(people_url) }
      format.xml  { head :ok }
    end
  end
  
  def bulk_email
    authorize! :manage, current_organization
    to_ids = params[:to].split(',').uniq
    
    to_ids.each do |id|
      person = Person.find_by_personID(id)
      PeopleMailer.enqueue.bulk_message(person.email, current_person.email, params[:subject], params[:body]) if !person.email.blank?
    end
    
    render :nothing => true
  end
  
  def bulk_sms
    authorize! :manage, current_organization
    to_ids = params[:to].split(',').uniq 

    to_ids.each do |id|
      person = Person.find_by_personID(id)
      if person.primary_phone_number
        if person.primary_phone_number.email_address.present?
          # Use email to sms if we have it
          from_email = current_person.primary_phone_number && current_person.primary_phone_number.email_address.present? ? 
                        current_person.primary_phone_number.email_address : current_person.email
          @sent_sms = SmsMailer.enqueue.text(person.primary_phone_number.email_address, "#{current_person.to_s} <#{from_email}>", params[:body])
        else
          # Otherwise send it as a text
          @sent_sms = SentSms.create!(message: params[:body][0..128] + ' Txt HELP for help STOP to quit', recipient: person.phone_number) 
        end
      end
    end
    
    render :nothing => true
  end
  
  def all
    fetch_people 
    
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
     
    render :partial => 'all'
  end

  def update_roles
    authorize! :manage, current_organization
    data = ""
    role_ids = params[:role_ids].split(',')
    person = Person.find(params[:person_id])
    organizational_roles = person.organizational_roles.where(organization_id: current_organization.id).collect { |role| role.id }
    OrganizationalRole.delete(organizational_roles)

    role_ids.each_with_index do |role_id, index|
       OrganizationalRole.create!(person_id: person.id, role_id: role_id, organization_id: current_organization.id) 
       data << "<span id='#{person.id}_#{role_id}' class='role_label role_#{role_id}'"
       data << "style='margin-right:4px;'" if index < role_ids.length - 1
       data << ">#{Role.find(role_id).to_s}</span>"
    end

    render :text => data
  end 
 
  protected
  
    def fetch_people
      org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
      @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles)
      @q = @people_scope.includes(:primary_phone_number, :primary_email_address)
      @q = @q.where('organizational_roles.role_id' => params[:role_id]) if !params[:role_id].blank?
      @q = @q.search(params[:q])
      @q.sorts = ['lastName asc', 'firstName asc'] if @q.sorts.empty?
      @all_people = @q.result(distinct: true)
      @people = @all_people.page(params[:page])
    end
    
    def authorize_read
      authorize! :read, Person
    end
    
    def authorize_merge
      authorize! :merge, Person
    end

end
