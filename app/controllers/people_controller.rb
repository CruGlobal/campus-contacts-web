require 'csv'
class PeopleController < ApplicationController
  before_filter :ensure_current_org
  before_filter :authorize_merge, only: [:merge, :confirm_merge, :do_merge, :merge_preview]
  before_filter :permissions_for_assign
  before_filter :labels_for_assign

  # GET /people
  # GET /people.xml
  def index
    authorize! :read, Person
    fetch_people(params)
    @permissions = current_organization.permissions
    @labels = current_organization.labels # Admin or Leader, all permissions will appear in the index div.permission_div_checkboxes but checkobx of the admin permission will be hidden
  end

  def all
    fetch_people(params)
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
    render :partial => 'all'
  end

  def hide_update_notice
    person = current_user
    person.settings[:hide_update_notice] = true
    person.save
    render nothing: true and return
  end

  def export
    index
    out = ""
    CSV.generate(out) do |rows|
      rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('people.index.gender'), t('people.index.email'), t('people.index.phone'), t('people.index.year_in_school')]
      @all_people.each do |person|
        rows << [person.first_name, person.last_name, person.gender, person.email, person.pretty_phone_number, person.year_in_school]
      end
    end
    filename = current_organization.to_s
    filename += " - #{Permission.find_by_id(params[:permission_id]).to_s.pluralize}" if params[:permission_id].present?
    send_data(out, :filename => "#{filename}.csv", :type => 'application/csv' )
  end

  # GET /people/1
  # GET /people/1.xml
  def show
    redirect_to profile_path(params[:id])
    # @person = Person.find(params[:id])
    # @assigned_tos = @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id).collect { |a| a.assigned_to.try(:name) }.compact.to_sentence
    # authorize!(:read, @person)
    # if @person.user && @person.friends.count == 0
    #   fb_auth = @person.user.authentications.first
    #   @person.update_friends(fb_auth) if fb_auth.present?
    # end
    # @org_friends = Person.where(fb_uid: Friend.followers(@person.id))
    # @labels = @person.labels_for_org_id(current_organization.id)
    # if can? :manage, @person
    #   @organizational_permissions = OrganizationalPermission.where(organization_id: current_organization, person_id: @person)
    #   @followup_comment = FollowupComment.new(organization: current_organization, commenter: current_person, contact: @person, status: @organizational_permissions.collect(&:followup_status)) if @organizational_permissions
    #   @followup_comments = FollowupComment.where(organization_id: current_organization, contact_id: @person).order('created_at desc')
    # end
    # @person = Present(@person)
  end

  # GET /people/new
  # def new
  #   names = params[:name].to_s.split(' ')
  #   @person = Person.new(:first_name => names[0], :last_name => names[1..-1].join(' '))
  #   @email = @person.email_addresses.new
  #   @phone = @person.phone_numbers.new
  # end

  # GET /people/1/edit

  def edit
    @person = Person.find(params[:id])
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
    @people = 1.upto(4).collect {|i| Person.find_by_id(params["person#{i}"]) if params["person#{i}"].present?}.compact
  end

  def confirm_merge
    @people = 1.upto(4).collect {|i| Person.find_by_id(params["person#{i}"]) if params["person#{i}"].present?}.compact

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
    @person = Person.find_by_id(params[:id])
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
      unless params[:person][:first_name].present?# && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
        render :nothing => true and return
      end
      @person = create_person(params[:person])
      @email = @person.email_addresses.first
      @phone = @person.phone_numbers.first

      if @person.save

        if params[:permissions].present?
          permission_ids = params[:permissions].keys.map(&:to_i)
          # we need a valid email address to make a leader
          if permission_ids.include?(Permission::USER_ID) || permission_ids.include?(Permission::ADMIN_ID)
            @new_person = @person.create_user! if @email.present? && @person.user.nil? # create a user account if we have an email address
            if @new_person && @new_person.save
              @person = @new_person
            end
          end

          permission_ids.each do |permission_id|
            begin
              @person.organizational_permissions.create(permission_id: permission_id, organization_id: current_organization.id, added_by_id: current_user.person.id)
            rescue OrganizationalPermission::InvalidPersonAttributesError
              @person.destroy
              @person = Person.new(params[:person])
              flash.now[:error] = I18n.t('people.create.error_creating_leader_no_valid_email') if permission_id == Permission::USER_ID.to_s
              flash.now[:error] = I18n.t('people.create.error_creating_admin_no_valid_email') if permission_id == Permission::ADMIN_ID.to_s
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
        #flash.now[:error] += "#{t('people.create.first_name_error')}<br />" unless @person.first_name.present?
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
    @person = Person.find(params[:id])
    @current_person = current_person
    if params[:followup_status].present?
      @new_status = params[:followup_status]
      @contact_permission = @person.permission_for_org(current_organization)
      Rails.logger.info @contact_permission.inspect
      if @contact_permission.present?
        @contact_permission.followup_status = @new_status
        @contact_permission.save!
      end
      Rails.logger.info @contact_permission.inspect
    end

    # Handle duplicate emails
    emails = []
		if params[:person][:email_address]
      params[:person][:email_address][:email].strip!
      emails = [params[:person][:email_address][:email]]
		elsif params[:person][:email_addresses_attributes]
			emails = params[:person][:email_addresses_attributes].collect{|_, v| v[:email].strip!; v[:email]}
		end
    emails.each do |email|
      p = @person.has_similar_person_by_name_and_email?(email)
			@person = @person.smart_merge(p) if p
      @person.reload
    end


    authorize! :edit, @person

    if params[:assigned_to_id].present?
      if params[:assigned_to_id] == 0
        @person.assigned_tos.where('contact_assignments.organization_id' => current_organization.id).delete_all
      else
        leader_ids = params[:assigned_to_id].split(",")
        @person.assigned_tos.delete_all
        leader_ids.each do |leader_id|
          if leader = current_organization.leaders.where(id: leader_id).try(:first)
            new_assignment = @person.assigned_tos.new(organization_id: current_organization.id, assigned_to_id: leader_id)
            new_assignment.save
          end
        end
      end
    end
    @assigned_tos = @person.assigned_to_people_by_org(current_organization)
    
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

    if i = current_organization.attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
      render :text => I18n.t('people.bulk_delete.cannot_delete_admin_error', names: Person.find(i).collect(&:name).join(", "))
      return
    end

    if current_organization.attempting_to_delete_or_archive_current_user_self_as_admin?(ids, current_person)
      render :text => I18n.t('people.index.cannot_delete_admin_error')
      return
    end

    if ids.present?
      current_organization.people.where('people.id' => ids).each do |person|
        current_organization.delete_person(person)
      end
    end


    render :text => I18n.t('people.bulk_delete.deleting_people_success')
  end

  def bulk_archive
    authorize! :manage, current_organization
    ids = params[:ids].to_s.split(',')

    if i = current_organization.attempting_to_delete_or_archive_all_the_admins_in_the_org?(ids)
      render :text => I18n.t('people.bulk_archive.cannot_archive_admin_error', names: Person.find(i).collect(&:name).join(", "))
      return
    end

    if current_organization.attempting_to_delete_or_archive_current_user_self_as_admin?(ids, current_person)
      render :text => I18n.t('people.index.cannot_archive_admin_error')
      return
    end

    if ids.present?
      current_organization.organizational_permissions.where(person_id: ids, archive_date: nil, deleted_at: nil).each do |ors|
        if(ors.permission_id == Permission::USER_ID)
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
    authorize! :manage, current_organization

    person = current_organization.people.find(params[:id])

    current_organization.delete_person(person)

    render nothing: true
  end

  def bulk_email
    authorize! :lead, current_organization
    to_ids = params[:to]

		person_ids = []
		if to_ids.present?
			ids = to_ids.split(',').uniq
			ids.each do |id|
				if id.upcase =~ /GROUP-/
					group = Group.find_by_id_and_organization_id(id.gsub("GROUP-",""), current_organization.id)
					group.group_memberships.collect{|p| person_ids << p.person_id.to_s } if group.present?
				elsif id.upcase =~ /ROLE-/
					permission = Permission.find(id.gsub("ROLE-",""))
					permission.members_from_permission_org(current_organization.id).collect{|p| person_ids << p.person_id.to_s } if permission.present?
        elsif id.upcase =~ /LABEL-/
					label = Label.find(id.gsub("LABEL-",""))
					label.label_contacts_from_org(current_organization).collect{|p| person_ids << p.id.to_s } if label.present?
				elsif id.upcase =~ /ALL-PEOPLE/
					current_organization.all_people.collect{|p| person_ids << p.id.to_s} if is_admin?
				else
					person_ids << id
				end
			end
		end

    person_ids.uniq.each do |id|
      person = Person.find_by_id(id)
      if person.present? && person.email.present?
        from = params[:reply_to_email] ? "do-not-reply@missionhub.com" : current_person.email
        @message = current_person.sent_messages.create(
          receiver_id: person.id,
          organization_id: current_organization.id,
          from: from,
          reply_to: from,
          to: person.email,
          sent_via: 'email',
          subject: params[:subject],
          message: params[:body]
        )
      end
    end
    render :nothing => true
  end

  def bulk_sms
    authorize! :lead, current_organization
    to_ids = params[:to]

		person_ids = []
		if to_ids.present?
			ids = to_ids.split(',').uniq
			ids.each do |id|
				if id.upcase =~ /GROUP-/
					group = Group.find_by_id_and_organization_id(id.gsub("GROUP-",""), current_organization.id)
					group.group_memberships.collect{|p| person_ids << p.person_id.to_s } if group.present?
				elsif id.upcase =~ /ROLE-/
					permission = Permission.find(id.gsub("ROLE-",""))
					permission.members_from_permission_org(current_organization.id).collect{|p| person_ids << p.person_id.to_s } if permission.present?
        elsif id.upcase =~ /LABEL-/
					label = Label.find(id.gsub("LABEL-",""))
					label.label_contacts_from_org(current_organization).collect{|p| person_ids << p.id.to_s } if label.present?
				elsif id.upcase =~ /ALL-PEOPLE/
					current_organization.all_people.collect{|p| person_ids << p.id.to_s} if is_admin?
				else
					person_ids << id
				end
			end
		end

    person_ids.uniq.each do |id|
    	person = Person.find_by_id(id)
      if person.present? && person.primary_phone_number
        if person.primary_phone_number.email_address.present? && params[:change_default_email]
          # Use email to sms if we have it

          current_person_send_as = current_person.phone_numbers.where("id = ?", params[:send_as_phone_number])
          from = I18n.t('general.default_email_from')
          if current_person_send_as.present?
            from = current_person_send_as.first.number.to_s + I18n.t("general.sms_append_to_phone_number")
          end

          @message = current_person.sent_messages.create(
            receiver_id: person.id,
            organization_id: current_organization.id,
            from: from,
            reply_to: from,
            to: person.primary_phone_number.email_address,
            sent_via: 'sms_email',
            message: params[:body]
          )
        else
          # Otherwise send it as a text
          @message = current_person.sent_messages.create(
            receiver_id: person.id,
            organization_id: current_organization.id,
            to: person.phone_number,
            sent_via: 'sms',
            message: params[:body]
          )
        end
      end
    end

    render :nothing => true
  end

  def bulk_comment
    authorize! :lead, current_organization

    receivers = params[:comment_receiver_ids]
    if receivers.present?
      to_ids = receivers.split(',')
      to_ids.each do |id|
        @interaction = Interaction.new(params[:interaction])
        @interaction.created_by_id = current_person.id
        @interaction.organization_id = current_organization.id
        @interaction.updated_by_id = current_person.id
        @interaction.receiver_id = id
        @interaction.privacy_setting = Interaction::DEFAULT_PRIVACY
        @interaction.interaction_type_id = InteractionType::COMMENT
        if @interaction.save
          @interaction.set_initiators(current_person.id)
        end
      end
    end
  end

  def update_permission_status
    response = false
    if person = Person.find(params[:person_id])
      permission = person.permission_for_org(current_organization)
      permission.followup_status = params[:status]
      permission.save
    end
    render :text => response
  end

  def update_permissions
    if current_user_permissions.include? Permission.admin
      authorize! :manage, current_organization
    else
      authorize! :lead, current_organization
    end

    data = ""
    person = Person.find(params[:person_id])
    permission_ids = params[:permission_ids].split(',').map(&:to_i)
    if permission_ids.present?
      permission_ids.each do |permission_id|
        new_permission = Permission.where(id: permission_id).first
        if new_permission.present?
          begin
            current_organization.change_person_permission(person, new_permission.id, current_person.id)
          rescue OrganizationalPermission::InvalidPersonAttributesError
            render 'update_leader_error', :locals => { :person => person } if new_permission.id == Permission::USER_ID
            render 'update_admin_error', :locals => { :person => person } if new_permission.id == Permission::ADMIN_ID
            return
          rescue ActiveRecord::RecordNotUnique

          end
          data << "<div id='#{person.id}_#{new_permission.id}' class='permission_label permission_#{new_permission.id}' style='margin-right:4px;'>#{new_permission.to_s}</div>"
        end
      end
    end

    render :text => data
  end

  def delete_permission(ors)
    begin
      ors.check_if_only_remaining_admin_permission_in_a_root_org
      ors.check_if_admin_is_destroying_own_admin_permission(current_person)
      ors.update_attributes({deleted_at: Date.today})
    rescue OrganizationalPermission::CannotDestroyPermissionError
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
        url = URI.escape("https://graph.facebook.com/search?q=#{term}&type=user&limit=5000&access_token=#{session[:fb_token]}")
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
      format.json { render text: @data.to_json }
      # we don't need an array for the dialog search result anymore so we are fine in just passing along the result from FB
    end
  end

  protected

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
    @people_scope = Person.joins(:organizational_permissions_including_archived).where('organizational_permissions.organization_id' => org_ids)
    @people_scope = @people_scope.where(id: @people_scope.archived_not_included.collect(&:id)) if params[:include_archived].blank? && params[:archived].blank?

    @q = @people_scope.includes(:primary_phone_number, :primary_email_address).joins(:organizational_permissions_including_archived)
    #when specific permission is selected from the directory
    @q = @q.where('organizational_permissions.permission_id = ? AND organizational_permissions.organization_id = ?', params[:permission], current_organization.id) unless params[:permission].blank?
    sort_by = ['last_name asc', 'first_name asc']

    #for searching
    if search_params[:search_type] == "basic"
      unless search_params[:query].blank?
        if search_params[:search_type] == "basic"
          @q = @q.joins("LEFT JOIN email_addresses AS emails ON emails.person_id = people.id")
                  .where("concat(first_name,' ',last_name) LIKE :search OR concat(last_name, ' ',first_name) LIKE :search OR emails.email LIKE :search",{:search => "%#{search_params[:query]}%"})
        end
      end
    else
      unless search_params[:permission].blank?
        if params[:include_archived]
          @q = @q.joins("INNER JOIN permissions ON permissions.id = organizational_permissions.permission_id")
                  .where("organizational_permissions.organization_id" => current_organization.id)
                  .where("permissions.id = :search",{:search => "#{search_params[:permission]}"})
                   sort_by.unshift("permissions.id")
          permission_tables_joint = true
        else
          @q = @q.joins("INNER JOIN permissions ON permissions.id = organizational_permissions.permission_id")
                  .where("organizational_permissions.archive_date" => nil, "organizational_permissions.deleted_at" => nil, "organizational_permissions.organization_id" => current_organization.id)
                  .where("permissions.id = :search",{:search => "#{search_params[:permission]}"})
                   sort_by.unshift("permissions.id")
          permission_tables_joint = true
        end
      end

      unless search_params[:gender].blank?
        @q = @q.where("gender = :search", {:search => "#{search_params[:gender]}"})
        sort_by.unshift("gender")
      end

      unless search_params[:email].blank?
        @q = @q.joins("LEFT JOIN email_addresses AS emails ON emails.person_id = people.id")
        .where("emails.email LIKE :search", {:search => "%#{search_params[:email]}%"})
        sort_by.unshift("emails.email")
      end

      unless search_params[:phone].blank?
        @q = @q.joins("LEFT JOIN phone_numbers AS phones ON phones.person_id = people.id")
        .where("phones.number LIKE :search", {:search => "%#{search_params[:phone]}%"})
        sort_by.unshift("phones.number")
      end

      unless search_params[:first_name].blank?
        @q = @q.where("first_name LIKE :search", {:search => "%#{search_params[:first_name]}%"})
        sort_by.unshift("first_name asc")
      end

      unless search_params[:last_name].blank?
        @q = @q.where("last_name LIKE :search", {:search => "%#{search_params[:last_name]}%"})
        sort_by.unshift("last_name asc")
      end
    end
    @q = @q.where(id: current_organization.people.archived(current_organization.id).collect(&:id)) unless params[:archived].blank?

    @q_sort = Person.where('1 <> 1').search(params[:search])
    # @q.sorts = sort_by if @q.sorts.empty?

    @all_people = @q.order(params[:search] && params[:search][:meta_sort] ? params[:search][:meta_sort] : sort_by)

    if params[:search].present? && params[:search][:meta_sort].include?("permission_id")
      order = params[:search][:meta_sort].include?("asc") ? params[:search][:meta_sort].gsub("asc", "desc") : params[:search][:meta_sort].gsub("desc", "asc")
      a = @q.result(distinct: false).order_by_highest_default_permission(order, permission_tables_joint)
      if params[:search][:meta_sort].include?("asc")
        a = a.reverse
        a = a.uniq_by { |a| a.id }
        a = a.reverse
        @all_people = @all_people.uniq_by { |a| a.id }
      end
      @all_people = a + @q.result(distinct: false).order_alphabetically_by_non_default_permission(order, permission_tables_joint)
    end

    @all_people = @all_people.where(id: current_organization.people.archived.where("organizational_permissions.archive_date > ? AND organizational_permissions.archive_date < ? AND organizational_permissions.deleted_at IS NULL", params[:archived_date], (params[:archived_date].to_date+1).strftime("%Y-%m-%d")).collect{|x| x.id}) unless params[:archived_date].blank?
    @people = Kaminari.paginate_array(@all_people).page(params[:page])
  end

  def authorize_read
    authorize! :read, Person
  end

  def authorize_merge
    if current_user_super_admin? || (current_organization.parent_organization_admins.include? current_user.person)
      authorize! :merge, Person
    else
      redirect_to "/people"
      flash[:error] = "You are not permitted to access that feature"
    end
  end

  def current_user_permissions
    current_user.person
    .organizational_permissions
    .where(:organization_id => current_organization)
    .collect { |r| Permission.find(r.permission_id) }
  end
end
