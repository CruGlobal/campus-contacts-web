require 'csv'
class PeopleController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize_merge, only: [:merge, :confirm_merge, :do_merge, :merge_preview]
  before_filter :roles_for_assign
  cache_sweeper :organization_sweeper, only: [:create, :update, :update_roles]

  # GET /people
  # GET /people.xml
  def index
    authorize! :read, Person
    fetch_people(params)
    @roles = current_organization.roles # Admin or Leader, all roles will appear in the index div.role_div_checkboxes but checkobx of the admin role will be hidden 
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
    @person = Person.find(params[:id])
    @assigned_tos = @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id).collect { |a| a.assigned_to.name }.to_sentence
    @org_friends = current_organization.people.find_friends_with_fb_uid(params[:id])
    authorize!(:read, @person)

    if can? :manage, @person
      @organizational_role = OrganizationalRole.where(organization_id: current_organization, person_id: @person, role_id: Role::CONTACT_ID).first
      @followup_comment = FollowupComment.new(organization: current_organization, commenter: current_person, contact: @person, status: @organizational_role.followup_status) if @organizational_role
      @followup_comments = FollowupComment.where(organization_id: current_organization, contact_id: @person).order('created_at desc')
    end
    @person = Present(@person)
  end

  # GET /people/new
  # def new
  #   names = params[:name].to_s.split(' ')
  #   @person = Person.new(:firstName => names[0], :lastName => names[1..-1].join(' '))
  #   @email = @person.email_addresses.new
  #   @phone = @person.phone_numbers.new
  # end

  # GET /people/1/edit

  def edit
    @person = current_organization.people.find(params[:id])
    authorize! :edit, @person
  end

  def involvement
    @person = current_organization.people.find(params[:id])
    authorize! :edit, @person
  end

  def search_ids
    if current_user_super_admin?
      @people = Person.search_by_name(params[:q])
    else
      @people = current_organization.people.search_by_name(params[:q])
    end
    respond_to do |wants|
      wants.json { render text: @people.collect(&:id).to_json }
    end
  end

  def merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact
  end

  def confirm_merge
    @people = 1.upto(4).collect {|i| Person.find_by_personID(params["person#{i}"]) if params["person#{i}"].present?}.compact

    if !current_user_super_admin? && can?(:manage, current_organization)
      names = @people.collect { |n| n.name.downcase }
      if names.uniq.length != 1
        #this means that one person doesn't have the same name with others
        redirect_to merge_people_path(params.slice(:person1, :person2, :person3, :person4)), alert: "You can only merge people with the EXACT same first and last name.<br/>Go to the person's profile and edit their name to make them exactly the same and then try again.".html_safe
        return false
      end
    end

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
    render :nothing => true and return false unless params[:id].to_i > 0
    @person = Person.find_by_personID(params[:id])
    respond_to do |wants|
      wants.js {  }
    end
  end

  def do_merge
    @keep = Person.find(params[:keep_id])
    params[:merge_ids].each do |id|
      person = Person.find(id)
      @keep = @keep.smart_merge(person)
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
          # we need a valid email address to make a leader
          if role_ids.include?(Role::LEADER_ID) || role_ids.include?(Role::ADMIN_ID)
            @new_person = @person.create_user! if @email.present? && @person.user.nil? # create a user account if we have an email address
            if @new_person && @new_person.save
              @person = @new_person
            end
          end

          role_ids.each do |role_id|
            begin
              @person.organizational_roles.create(role_id: role_id, organization_id: current_organization.id, added_by_id: current_user.person.id)
            rescue OrganizationalRole::InvalidPersonAttributesError
              @person.destroy
              @person = Person.new(params[:person])
              flash.now[:error] = I18n.t('people.create.error_creating_leader_no_valid_email') if role_id == Role::LEADER_ID.to_s
              flash.now[:error] = I18n.t('people.create.error_creating_admin_no_valid_email') if role_id == Role::ADMIN_ID.to_s
              params[:error] = 'true'
              render and return
            rescue ActiveRecord::RecordNotUnique
            
            end
          end
        else
          current_organization.add_involved(@person)
        end

        if params.has_key?(:add_to_group)
          render json: @person
        else
          respond_to do |wants|
            wants.html { redirect_to :back }
            wants.mobile { redirect_to :back }
            wants.js
          end
        end
      else 
        flash.now[:error] = ''
        #flash.now[:error] += "#{t('people.create.firstname_error')}<br />" unless @person.firstName.present?
        flash.now[:error] += "#{t('people.create.phone_number_error')}<br />" if @phone && !@phone.valid?
        if @email && !@email.is_unique?
          flash.now[:error] += "#{t('people.create.email_taken')}<br />" 
        elsif @email && !@email.valid?
          flash.now[:error] += "#{t('people.create.email_error')}<br />" 
        end
        params[:error] = 'true'
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update
    @person = current_organization.people.find(params[:id])

    # Handle duplicate emails
    emails = []
		if params[:person][:email_address]
      emails = [params[:person][:email_address][:email]]
		elsif params[:person][:email_addresses_attributes]
			emails = params[:person][:email_addresses_attributes].collect{|_, v| v[:email]}
		end
    emails.each do |email|
      p = @person.has_similar_person_by_name_and_email?(email)
			@person = @person.smart_merge(p) if p
      @person.reload
    end


    authorize! :edit, @person

    respond_to do |format|
      if @person.update_attributes(params[:person])
        @person.update_date_attributes_updated
        format.html { redirect_to(@person, notice: 'Person was successfully updated.') }
        format.xml  { head :ok }
        params[:update] = 'true'
        format.js
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @person.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def bulk_delete
    authorize! :manage, current_organization
    ids = params[:ids].to_s.split(',')
    
    if i = attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
      render :text => I18n.t('people.bulk_delete.cannot_delete_admin_error', names: Person.find(i).collect(&:name).join(", "))
      return
    end
    
    if attempting_to_delete_or_archive_current_user_self_as_admin?(ids)
      render :text => I18n.t('people.index.cannot_delete_admin_error')
      return
    end
    
    if ids.present?
      current_organization.organization_memberships.where(:person_id => ids).destroy_all
      current_organization.organizational_roles.where(:person_id => ids, :deleted => false).each do |ors|
        if(ors.role_id == Role::LEADER_ID)
          ca = Person.find(ors.person_id).contact_assignments.where(organization_id: current_organization.id).all
          ca.collect(&:destroy)
        end
        ors.delete
      end
    end
    
    
    render :text => I18n.t('people.bulk_delete.deleting_people_success')
    #respond_to do |format|
    #  format.js
    #end
  end
  
  def bulk_archive
    authorize! :manage, current_organization
    ids = params[:ids].to_s.split(',')
    
    if i = attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
      render :text => I18n.t('people.bulk_archive.cannot_archive_admin_error', names: Person.find(i).collect(&:name).join(", "))
      return
    end
    
    if attempting_to_delete_or_archive_current_user_self_as_admin?(ids)
      render :text => I18n.t('people.index.cannot_archive_admin_error')
      return
    end
    
    if ids.present?
      current_organization.organization_memberships.where(:person_id => ids).destroy_all
      current_organization.organizational_roles.where(:person_id => ids, :archive_date => nil, :deleted => false).each do |ors|
        if(ors.role_id == Role::LEADER_ID)
          ca = Person.find(ors.person_id).contact_assignments.where(organization_id: current_organization.id).all
          ca.collect(&:destroy)
        end
        ors.archive
      end
    end
    
    render :text => I18n.t('people.bulk_archive.archiving_people_success')
  end
  # 
  # # DELETE /people/1
  # # DELETE /people/1.xml
  def destroy
    @org_role = current_organization.organizational_roles.find_by_person_id(params[:id])
    @org_role.destroy if @org_role.present?
    render nothing: true
  end

  def bulk_email
    authorize! :lead, current_organization
    to_ids = params[:to].split(',').uniq

    to_ids.each do |id|
      person = Person.find_by_personID(id)
      PeopleMailer.enqueue.bulk_message(person.email, current_person.email, params[:subject], params[:body]) if !person.email.blank?
    end

    render :nothing => true
  end

  def bulk_sms
    authorize! :lead, current_organization
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
          @sent_sms = SentSms.create!(message: params[:body], recipient: person.phone_number) # + ' Txt HELP for help STOP to quit'
        end
      end
    end

    render :nothing => true
  end

  def bulk_comment
    authorize! :lead, current_organization
    to_ids = params[:to].split(',').uniq

    to_ids.each do |id|
      person = Person.find_by_personID(id)
      fc = FollowupComment.create(params[:followup_comment])
      fc.contact_id = id
      fc.comment = params[:body]
      fc.status = person.organizational_roles.first.followup_status
      fc.save
    end

    render :nothing => true
  end



  def update_roles
    if current_user_roles.include? Role.admin
      authorize! :manage, current_organization
    else
      authorize! :lead, current_organization
    end

    data = ""
    person = Person.find(params[:person_id])

    role_ids = params[:role_ids].split(',').map(&:to_i)


    new_roles = params[:role_ids].split(',').map(&:to_i)
    old_roles = person.organizational_roles.where(organization_id: current_organization.id).collect { |role| role.role_id }
    some_roles = params[:some_role_ids].nil? ? [] : params[:some_role_ids].split(',').map(&:to_i) # roles that only SOME persons have

    new_roles = new_roles - some_roles #remove roles that SOME of the persons have. We should not touch them. They are disabled in the views anyway.

    some_roles = old_roles if params[:include_old_roles] == "yes"
    to_be_added_roles = new_roles - old_roles
    to_be_removed_roles = old_roles - new_roles - some_roles

    person.organizational_roles.where(organization_id: current_organization.id, role_id: to_be_removed_roles).each do |organizational_role|
      return unless delete_role(organizational_role)
    end
    
    all = to_be_added_roles | (new_roles & old_roles) | (old_roles & some_roles)
    all.sort!
    all.each_with_index do |role_id, index|    
      begin       
        ors = OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id: person.id, role_id: role_id, organization_id: current_organization.id, added_by_id: current_user.person.id) if to_be_added_roles.include?(role_id)
        ors.update_attributes({:deleted => false, :end_date => '', :archive_date => nil}) unless ors.nil?
      rescue OrganizationalRole::InvalidPersonAttributesError
        render 'update_leader_error', :locals => { :person => person } if role_id == Role::LEADER_ID
        render 'update_admin_error', :locals => { :person => person } if role_id == Role::ADMIN_ID
        return
      rescue ActiveRecord::RecordNotUnique

      end

      data << "<span id='#{person.id}_#{role_id}' class='role_label role_#{role_id}'"
      data << "style='margin-right:4px;'" if index < all.length - 1
      data << ">#{Role.find(role_id).to_s}</span>"
    end

    render :text => data
  end 
  
  def delete_role(ors)
    begin
      ors.check_if_only_remaining_admin_role_in_a_root_org
      ors.check_if_admin_is_destroying_own_admin_role(current_person)
      ors.update_attributes({:archive_date => Date.today})
    rescue OrganizationalRole::CannotDestroyRoleError
      render 'cannot_delete_admin_error'
      return false
    end
  end

  def facebook_search
    url = params[:url]
    data = Array.new

    if uri?(params[:term]) # if term is a url ...
      id = get_fb_user_id_from_url(params[:term])
      url = URI.escape("https://graph.facebook.com/#{id}")

      begin
        @json = JSON.parse(RestClient.get(url, { accept: :json}))
      rescue RestClient::ResourceNotFound
        @json = nil
        @data = []
      end

      if @json
        #flash[:checker] = r.count # for testing purposes
        @data = [{'name' => @json['name'], 'id' => @json['id']},
                {'name' => t('general.match_found'), 'id' => nil}]
      else
        #flash[:checker] = 0 # for testing purposes
        @data = [{'name' => t('people.edit.no_results'), 'id' => nil }]
      end

    else
      # if a url exist in the param, then we're using FB's previous/next url to fetch the data
      if url.nil?
        # else, this is an initial search so we construct the url
        term = "\"#{params[:term]}\""
        url = URI.escape("https://graph.facebook.com/search?q=#{term}&type=user&limit=24&access_token=#{session[:fb_token]}")
      end

      begin
        resp = RestClient.get url, { accept: :json}
        @json = JSON.parse(resp)
      rescue
        raise resp.inspect
      end

      @data = []

      if @json['data'].size > 0
        # construct the json result - autocomplete only accepts an array
        @json['data'].each do |d|
          @data << { 'name' => d['name'] , 'id' => d['id'] }
        end

        @data <<  {'name' => t('people.edit.more_facebook_matches'), 'id' => @json['paging']['next'] } if data.length == 24
      else
        @data <<  {'name' => t('people.edit.no_results'), 'id' => nil }
      end

    end

    respond_to do |format|
      format.js { render json: params[:url].nil? ? @data : @json } # we don't need an array for the dialog search result anymore so we are fine in just passing along the result from FB
    end
  end

  protected
  
  def attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
    admin_ids = current_organization.parent_organization_admins.collect(&:personID)
    i = admin_ids & ids.collect(&:to_i)
    return i if (admin_ids - i).blank?
    false
  end
  
  def attempting_to_delete_or_archive_current_user_self_as_admin?(ids)
    return true unless ([current_person.personID] & ids.collect(&:to_i)).blank?
    false
  end

  def uri?(string)
    string.include?("http://") || string.include?("https://") ? true : false
  end


=begin
    def uri?(string)
      uri = URI.parse(string)
      %w( http https ).include?(uri.scheme)
    rescue URI::BadURIError
      false
    end
=end



  def get_fb_user_id_from_url(string)
    # e.g. https://graph.facebook.com/nmfdelacruz)
    if string.include?("id=")
      string.split('id=').last
    else
      string.split('/').last
    end
  end


  def fetch_people(search_params = {})
    org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
    @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles_including_archived)
    @people_scope = @people_scope.where(personID: @people_scope.archived_not_included.collect(&:personID)) if params[:include_archived].blank? && params[:archived].blank?
    #Person.archived_not_included query must be fixed so that we don't have to query from db twice such as the line above
    
    @q = @people_scope.includes(:primary_phone_number, :primary_email_address)
    #when specific role is selected from the directory
    @q = @q.where('organizational_roles.role_id = ? AND organizational_roles.organization_id = ? AND organizational_roles.deleted = 0', params[:role], current_organization.id) unless params[:role].blank?
    sort_by = ['lastName asc', 'firstName asc']

    #for searching
    if search_params[:search_type] == "basic"
      unless search_params[:query].blank?
        if search_params[:search_type] == "basic"
          @q = @q.select("ministry_person.*, email_addresses.*")
          .joins("LEFT JOIN email_addresses AS emails ON emails.person_id = ministry_person.personID")
          .where("concat(firstName,' ',lastName) LIKE :search OR
                           concat(lastName, ' ',firstName) LIKE :search OR
                           emails.email LIKE :search", 
                           {:search => "%#{search_params[:query]}%"})
        end
      end
    else      
      unless search_params[:role].blank?
        if params[:include_archived]
          @q = @q.select("ministry_person.*, roles.*")
          .joins("LEFT JOIN organizational_roles AS org_roles ON 
                   org_roles.person_id = ministry_person.personID")
                   .joins("INNER JOIN roles ON roles.id = org_roles.role_id")
                   .where("roles.id = :search",
                          {:search => "#{search_params[:role]}"})
                   sort_by.unshift("roles.id")
          role_tables_joint = true
        else
          @q = @q.select("ministry_person.*, roles.*")
          .joins("LEFT JOIN organizational_roles AS org_roles ON 
                   org_roles.person_id = ministry_person.personID")
                   .joins("INNER JOIN roles ON roles.id = org_roles.role_id").where("org_roles.archive_date" => nil)
                   .where("roles.id = :search",
                          {:search => "#{search_params[:role]}"})
                   sort_by.unshift("roles.id")
          role_tables_joint = true
        end
      end

      unless search_params[:gender].blank?
        @q = @q.where("gender = :search", {:search => "#{search_params[:gender]}"})
        sort_by.unshift("gender")
      end

      unless search_params[:email].blank?
        @q = @q.select("ministry_person.*, email_addresses.*")
        .joins("LEFT JOIN email_addresses AS emails ON emails.person_id = ministry_person.personID")  
        .where("emails.email LIKE :search", {:search => "%#{search_params[:email]}%"})
        sort_by.unshift("emails.email")
      end

      unless search_params[:phone].blank?
        @q = @q.select("ministry_person.*, phone_numbers.*")
        .joins("LEFT JOIN phone_numbers AS phones ON phones.person_id = ministry_person.personID")
        .where("phones.number LIKE :search", {:search => "%#{search_params[:phone]}%"})
        sort_by.unshift("phones.number")
      end

      unless search_params[:first_name].blank?
        @q = @q.where("firstName LIKE :search", {:search => "%#{search_params[:first_name]}%"}) 
        sort_by.unshift("firstName asc") 
      end

      unless search_params[:last_name].blank?
        @q = @q.where("lastName LIKE :search", {:search => "%#{search_params[:last_name]}%"})
        sort_by.unshift("lastName asc")
      end
    end

    @q = @q.where(personID: current_organization.people.archived(current_organization.id).collect(&:personID)) unless params[:archived].blank?

    @q = @q.search(params[:q])
    @q.sorts = sort_by if @q.sorts.empty?
    @all_people = @q.result(distinct: false).order(params[:q] && params[:q][:s] ? params[:q][:s] : sort_by)
    if params[:q].present? && params[:q][:s].include?("role_id")
      order = params[:q][:s].include?("asc") ? params[:q][:s].gsub("asc", "desc") : params[:q][:s].gsub("desc", "asc")
      a = @q.result(distinct: false).order_by_highest_default_role(order, role_tables_joint)
      if params[:q][:s].include?("asc")
        a = a.reverse
        a = a.uniq_by { |a| a.id }
        a = a.reverse
      end
      @all_people = a + @q.result(distinct: false).order_alphabetically_by_non_default_role(order, role_tables_joint)
      @all_people = @all_people.uniq_by { |a| a.id }
    end
    
    @all_people = @all_people.where(personID: current_organization.people.archived.where("organizational_roles.archive_date > ? AND organizational_roles.archive_date < ?", params[:archived_date], (params[:archived_date].to_date+1).strftime("%Y-%m-%d")).collect{|x| x.personID}) unless params[:archived_date].blank?
    @people = Kaminari.paginate_array(@all_people).page(params[:page])
  end

  def authorize_read
    authorize! :read, Person
  end

  def authorize_merge
    if current_user_super_admin? || (current_organization.admins.include? current_user.person)
      authorize! :merge, Person
    else
      redirect_to "/people"
      flash[:error] = "You are not permitted to access that feature"
    end
  end

  def current_user_roles
    current_user.person
    .organizational_roles
    .where(:organization_id => current_organization)
    .collect { |r| Role.find(r.role_id) }
  end
end
