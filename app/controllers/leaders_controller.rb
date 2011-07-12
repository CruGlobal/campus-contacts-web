class LeadersController < ApplicationController
  respond_to :html, :js
  
  def leader_sign_in
    # Reconcile the person comeing from a leader link with the link itself.
    # This is for the case where the person gets entered with one email, but has a different email for FB
    if params[:token] && params[:user_id]
      user = User.find(params[:user_id])
      if user.remember_token == params[:token] && user.remember_token_expires_at >= Time.now
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
      query = params[:name].strip.split(' ')
      first, last = query[0].to_s + '%', query[1].to_s + '%'
      if last == '%'
        conditions = ["preferredName like ? OR firstName like ? OR lastName like ?", first, first, first]
      else
        conditions = ["(preferredName like ? OR firstName like ?) AND lastName like ?", first, first, last]
      end

      @people = Person.where(conditions).includes(:user)
      @people = @people.limit(10) unless params[:show_all].to_s == 'true'
      @total = Person.where(conditions).count
      render :layout => false
    else
      render :nothing => true
    end
  end

  def new
    names = params[:name].to_s.split(' ')
    @person = Person.new(:firstName => names[0], :lastName => names[1..-1].join(' '))
    @email = @person.email_addresses.new
    @phone = @person.phone_numbers.new
  end

  def destroy
    @person = Person.find(params[:id])
    roles = OrganizationalRole.find_all_by_person_id_and_organization_id_and_role_id(@person.id, current_organization.id, Role.leader_ids)
    if roles
      roles.collect(&:destroy)
      # make any contacts assigned to this person go back to unassinged
      @contacts = @person.contact_assignments.where(organization_id: current_organization.id).all
      @contacts.collect(&:destroy)
      # If this person doesn't have any other roles in the org, destroy the membership too
      if OrganizationalRole.find_all_by_person_id_and_organization_id(@person.id, current_organization.id).empty?
        OrganizationMembership.find_by_person_id_and_organization_id(@person.id, current_organization.id).try(:destroy)
      end
    end
  end

  def create
    @person ||= Person.find(params[:person_id]) if params[:person_id]
    OrganizationMembership.find_or_create_by_person_id_and_organization_id(@person.id, current_organization.id)
    OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(@person.id, current_organization.id, Role.leader.id)
    render :create
  end
  
  def add_person
    @person = create_person(params[:person])
    required_fields = {'First Name' => @person.firstName, 'Last Name' => @person.lastName, 'Gender' => @person.gender, 'Email' => @email.try(:email), 'Phone' => @phone.try(:number)}
    @person.valid?; @email.try(:valid?); @phone.try(:valid?)
    unless required_fields.values.all?(&:present?)
      flash.now[:error] = "Please fill in all fields<br />"
      required_fields.each do |k,v|
        flash.now[:error] += k + " is required.<br />" unless v.present?
      end
      render :new and return
    end
    # Make sure we have a user for this person
    unless @person.user
      @person.user = User.create!(:username => @email.email, :email => @email.email, :password => SecureRandom.hex(10))
    end
    @person.save!
    
    # Notify the new user if we're supposed to
    if params[:notify] == '1'
      token = SecureRandom.hex(12)
      @person.user.remember_token = token
      @person.user.remember_token_expires_at = 1.month.from_now
      @person.user.save(validate: false)
      LeaderMailer.added(@person, current_person, current_organization, token).deliver
    end
    create and return
  end

end
