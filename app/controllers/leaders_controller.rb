class LeadersController < ApplicationController
  respond_to :html, :js

  def leader_sign_in
    # Reconcile the person comeing from a leader link with the link itself.
    # This is for the case where the person gets entered with one email, but has a different email for FB
    if params[:token] && params[:user_id]
      user = User.find(params[:user_id])
      if current_user != user && user.remember_token == params[:token] && user.remember_token_expires_at >= Time.now
        # the link was valid merge the created user into the current user
        current_user.merge(user)
        user.destroy
        redirect_to '/contacts/mine'
      else
        redirect_to user_root_path
      end
    else
      redirect_to user_root_path
    end
  end

  def search
    if params[:name].present?
      scope = Person.search_by_name(params[:name], [current_organization.id])
      @people = scope.includes(:user)
      if params[:show_all].to_s == 'true'
        @total = @people.all.length
      else
        @people = @people.limit(10)
        @total = scope.count
      end
      @people
      render :layout => false
    else
      render :nothing => true
    end
  end

  def new
    names = params[:name].to_s.split(' ')
    @person = Person.new(:first_name => names[0], :last_name => names[1..-1].join(' '))
    @email = @person.email_addresses.new
    @phone = @person.phone_numbers.new
  end

  def destroy
    @person = Person.find(params[:id])
    permissions = OrganizationalPermission.find_all_by_person_id_and_organization_id_and_permission_id_and_archive_date_and_deleted_at(@person.id, current_organization.id, Permission.user_ids, nil, nil)
    if permissions
      permissions.each do |r|
        r.archive
      end
      # make any contacts assigned to this person go back to unassinged
      @contacts = @person.contact_assignments.where(organization_id: current_organization.id).all
      @contacts.collect(&:destroy)
    end
  end

  def create
    @organization = current_organization
    if @person
      @notify = params[:notify] == '1'
    else
      @person = Person.find(params[:person_id])
      @notify = true
    end
    # Make sure we have a user for this person
    unless @person.user
      @new_person = @person.create_user!
      unless @new_person
        @person.reload
        # we need a valid email address to make a leader
        @email = @person.primary_email_address || @person.email_addresses.new
        @phone = @person.primary_phone_number || @person.phone_numbers.new
        flash[:error] = I18n.t('leaders.create.no_user_account')
        render :edit and return
      end
      @person = @new_person
    end
    current_organization.add_leader(@person, current_person)
    render :create
  end

  def update
    @person = Person.find(params[:id])
    if params[:person]
      email_attributes = params[:person].delete(:email_address) || {}
      phone_attributes = params[:person].delete(:phone_number) || {}
      if email_attributes[:email].present?
        @email = @person.email_addresses.find_or_create_by_email(email_attributes[:email])
      end
      if phone_attributes[:phone].present?
        @phone = @person.phone_numbers.find_or_create_by_number(PhoneNumber.strip_us_country_code(phone_attributes[:phone]))
      end
      @person.save
      @person.update_attributes(params[:person])
    end
    @required_fields = {'First Name' => @person.first_name, 'Last Name' => @person.last_name, 'Gender' => @person.gender, 'Email' => @email.try(:email)}
    @person.valid?; @email.try(:valid?); @phone.try(:valid?)
    unless @required_fields.values.all?(&:present?)
      flash.now[:error] = "Please fill in all fields<br />"
      @required_fields.each do |k,v|
        flash.now[:error] += k + " is required.<br />" unless v.present?
      end
      flash.now[:error] = "<font color='red'>" + flash.now[:error] + "</font>"
      render :edit and return
    end
    create and return
  end

  def add_person

    @person = create_person(params[:person])
    @email = @person.email_addresses.first
    @phone = @person.phone_numbers.first

    @required_fields = {'First Name' => @person.first_name, 'Last Name' => @person.last_name, 'Gender' => @person.gender, 'Email' => @email.try(:email)}
    @person.valid?; @email.try(:valid?); @phone.try(:valid?)

    error_message = ''
    unless @required_fields.values.all?(&:present?)
      @required_fields.each do |k,v|
        error_message += k + " is required.<br />" unless v.present?
      end
    end

    error_message += "Email Address isn't valid.<br />" if @email.present? && !@email.valid?

    if error_message.present?
      flash.now[:error] = "<font color='red'>" + error_message + "</font>"
      render :new and return
    end

    @person.email ||= @email.email
    @person.save!

    create and return
  end

end
