class OrganizationMembershipsController < ApplicationController
  # GET /organization_memberships
  # GET /organization_memberships.xml
  def index
    @organization_memberships = current_person.organization_memberships

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @organization_memberships }
    end
  end

  # GET /organization_memberships/1
  # GET /organization_memberships/1.xml
  def show
    @organization_membershipship = current_person.organization_memberships.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @organization_membershipship }
    end
  end

  # GET /organization_memberships/1/edit
  def edit
    @organization_membershipship = current_person.organization_memberships.find(params[:id])
  end

  # POST /organization_memberships
  # POST /organization_memberships.xml
  def create
    @organization_membershipship = current_person.organization_memberships.new(organization_id: params[:organization_id])

    respond_to do |format|
      if @organization_membershipship.save
        format.html do 
          @org = @organization_membershipship.organization 
          # if @org.root.requires_validation?
          #   case @org.root.validation_method
          #   when 'relay'
          #     redirect_to('https://signin.ccci.org/cas/login?service=' + validate_person_organization_membership_url(current_person, @organization_membershipship))
          #   end
          # else
            redirect_to(session[:return_to].present? ? session[:return_to] : :back, notice: 'Organization membership was successfully created.') 
          # end
        end
        format.xml  { render xml: @organization_membershipship, status: :created, location: @organization_membershipship }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @organization_membershipship.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organization_memberships/1
  # PUT /organization_memberships/1.xml
  def update
    @organization_membershipship = current_person.organization_memberships.find(params[:id])

    respond_to do |format|
      if @organization_membershipship.update_attributes(params[:organization_membershipship])
        format.html { redirect_to(@organization_membershipship, notice: 'Organization membership was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @organization_membershipship.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organization_memberships/1
  # DELETE /organization_memberships/1.xml
  def destroy
    @organization_membershipship = current_person.organization_memberships.find(params[:id])
    @organization_membershipship.destroy

    respond_to do |format|
      format.html { redirect_to(person_organization_memberships_path(current_person)) }
      format.js   { render nothing: true }
      format.xml  { head :ok }
    end
  end
  
  # def validate
  #   @organization_membershipship = current_person.organization_memberships.includes(:organization).find(params[:id])
  #   org = @organization_membershipship.organization
  #   @valid = false
  #   user = current_user
  #   case org.root.validation_method
  #   when 'relay'
  #     if RubyCAS::Filter.filter(self)
  #       guid = get_guid_from_ticket(session[:cas_last_valid_ticket])
  #       # See if we have a user with this guid
  #       user = User.find_by_globallyUniqueID(guid)
  #       unless current_user == user
  #         sign_out(current_user)
  #         old_user = User.find(current_user.id)
  #         user.merge(old_user)
  #         sign_in(user)
  #       end
  #       if user.person.isStaff?
  #         @valid = true
  #       end
  #     end
  #   end
  #   if @valid
  #     (@organization_membershipship.frozen? ? user.person.organization_memberships.where(organization_id: org.id).first : @organization_membershipship).update_attribute(:validated, true)
  #     redirect_to(session[:return_to].present? ? session[:return_to] : :back, notice: 'Organization membership was successfully created.') 
  #     return
  #   else
  #     # @organization_membershipship.destroy
  #     redirect_to person_organization_memberships_path(user.person), error: "Validation of membership failed"
  #     return
  #   end
  #   
  # end
  
  def set_current
    org = Organization.find(params[:id])
    orgs_i_have_access_to = current_person.organizations.collect {|o| o.subtree_ids}.flatten
    if orgs_i_have_access_to.include?(org.id)
      session[:current_organization_id] = params[:id]
    end
    redirect_to request.referrer ? request.referrer.split('?').first : '/contacts'
  end
  
  def set_primary
    org = Organization.find(params[:id])
    current_person.primary_organization = org
    session[:current_organization_id] = params[:id]
    expire_fragment("org_nav/#{current_person.id}")
    redirect_to request.referrer ? :back : '/contacts'
  end
  
end
