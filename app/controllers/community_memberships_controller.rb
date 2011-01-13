class CommunityMembershipsController < ApplicationController
  # GET /community_memberships
  # GET /community_memberships.xml
  def index
    @community_memberships = CommunityMembership.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @community_memberships }
    end
  end

  # GET /community_memberships/1
  # GET /community_memberships/1.xml
  def show
    @community_membership = CommunityMembership.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @community_membership }
    end
  end

  # GET /community_memberships/new
  # GET /community_memberships/new.xml
  def new
    @community_membership = CommunityMembership.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @community_membership }
    end
  end

  # GET /community_memberships/1/edit
  def edit
    @community_membership = CommunityMembership.find(params[:id])
  end

  # POST /community_memberships
  # POST /community_memberships.xml
  def create 
    person_id = !(params[:person_id]) ? current_user.person.id : params[:person_id] 
    community_id = params[:community_membership] ? params[:community_membership][:community_id] : params[:community_id]
    params_created = {:person_id => person_id, :community_id => community_id}
    @community_membership = CommunityMembership.new(params_created)

    respond_to do |format|
      if @community_membership.save
        format.html { redirect_to(@community_membership, :notice => 'Community membership was successfully created.') }
        format.xml  { render :xml => @community_membership, :status => :created, :location => @community_membership }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @community_membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /community_memberships/1
  # PUT /community_memberships/1.xml
  def update
    @community_membership = CommunityMembership.find(params[:id])

    respond_to do |format|
      if @community_membership.update_attributes(params[:community_membership])
        format.html { redirect_to(@community_membership, :notice => 'Community membership was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @community_membership.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /community_memberships/1
  # DELETE /community_memberships/1.xml
  def destroy
    @community_membership = CommunityMembership.find(params[:id])
    @community_membership.destroy

    respond_to do |format|
      format.html { redirect_to(community_memberships_url) }
      format.xml  { head :ok }
    end
  end
end
